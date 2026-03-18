#!/usr/bin/env bash
# sync-upstream.sh — 从 openakita/openakita 同步指定目录的变更到分仓库
# 用法:
#   ./sync-upstream.sh backend   # 同步后端仓库
#   ./sync-upstream.sh frontend  # 同步前端仓库

set -e

TARGET=${1:-""}
UPSTREAM_URL="https://github.com/openakita/openakita.git"

if [ -z "$TARGET" ]; then
  echo "用法: $0 [backend|frontend]"
  exit 1
fi

echo "==> 拉取上游最新代码..."
git fetch upstream main 2>/dev/null || {
  git remote add upstream "$UPSTREAM_URL"
  git fetch upstream main
}

UPSTREAM_SHA=$(git rev-parse upstream/main | head -c 8)
BRANCH="sync/upstream-${UPSTREAM_SHA}"

echo "==> 创建同步分支: $BRANCH"
git checkout -b "$BRANCH" 2>/dev/null || git checkout "$BRANCH"

if [ "$TARGET" = "backend" ]; then
  echo "==> 同步后端目录..."

  # 用 checkout 只取后端相关目录的上游版本
  DIRS=(
    "src/openakita"
    "skills"
    "channels"
    "auth_api"
    "mcps"
    "identity"
    "data"
    "prompts"
    "scripts"
    "tests"
    "pyproject.toml"
    "VERSION"
    "requirements.txt"
    "README.md"
    "README_CN.md"
  )

  for d in "${DIRS[@]}"; do
    if git ls-tree -d upstream/main "$d" >/dev/null 2>&1 || \
       git ls-tree upstream/main "$d" >/dev/null 2>&1; then
      git checkout upstream/main -- "$d" 2>/dev/null && echo "  ✓ $d" || echo "  - $d (跳过)"
    fi
  done

elif [ "$TARGET" = "frontend" ]; then
  echo "==> 同步前端目录..."

  # 前端目录在上游是 apps/setup-center/src/
  # 需要把 apps/setup-center/src/ → src/  (去掉前缀)
  SUBDIRS=(
    "src/components"
    "src/views"
    "src/platform"
    "src/i18n"
    "src/icons.tsx"
    "src/types.ts"
    "src/styles.css"
  )

  for d in "${SUBDIRS[@]}"; do
    UPSTREAM_PATH="apps/setup-center/$d"
    if git ls-tree upstream/main "$UPSTREAM_PATH" >/dev/null 2>&1; then
      git checkout upstream/main -- "$UPSTREAM_PATH" 2>/dev/null || true
      # 移动到正确路径（去掉 apps/setup-center/ 前缀）
      if [ -e "$UPSTREAM_PATH" ]; then
        mkdir -p "$(dirname "$d")"
        cp -r "$UPSTREAM_PATH" "$d"
        git rm -rf "$UPSTREAM_PATH" --quiet 2>/dev/null || true
        git add "$d"
        echo "  ✓ $d (from $UPSTREAM_PATH)"
      fi
    else
      echo "  - $UPSTREAM_PATH (不存在，跳过)"
    fi
  done

  # 清理临时的 apps/ 目录
  rm -rf apps/ 2>/dev/null || true

  # 特殊处理：保留我们自己的 vite.config.ts、package.json、src/platform/detect.ts
  echo ""
  echo "  ⚠️  以下文件需要手动检查（我们有自己的改动）:"
  echo "     - vite.config.ts"
  echo "     - package.json"
  echo "     - src/platform/detect.ts"
  git checkout HEAD -- vite.config.ts package.json src/platform/detect.ts 2>/dev/null || true
fi

echo ""
echo "==> 查看变更..."
git diff --stat HEAD

echo ""
echo "==> 完成！请检查变更后手动 commit:"
echo "    git add -A && git commit -m 'chore: sync from upstream openakita/openakita @ ${UPSTREAM_SHA}'"
echo "    git push origin $BRANCH"
echo "    # 然后在 GitHub 上创建 PR"
