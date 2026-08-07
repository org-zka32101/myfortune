#!/bin/bash
# iOS Build Verification and Fix Script
# This script verifies the iOS project structure and fixes common issues

set -e

PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$PROJECT_DIR"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}iOS Build Verification${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

ISSUES=0
FIXES=0

# ============================================
# Check 1: Xcode Project File
# ============================================
echo -e "${YELLOW}[1/8]${NC} Checking Xcode project..."
if [ -f "myfortune.xcodeproj/project.pbxproj" ]; then
  echo -e "${GREEN}✅${NC} Xcode project found"
else
  echo -e "${RED}❌${NC} Xcode project NOT found"
  ISSUES=$((ISSUES + 1))
fi

# ============================================
# Check 2: Swift Source Files
# ============================================
echo -e "${YELLOW}[2/8]${NC} Checking Swift files..."
SWIFT_COUNT=$(find myfortune -name "*.swift" -type f | wc -l)
if [ "$SWIFT_COUNT" -gt 0 ]; then
  echo -e "${GREEN}✅${NC} Found $SWIFT_COUNT Swift files"
else
  echo -e "${RED}❌${NC} No Swift files found"
  ISSUES=$((ISSUES + 1))
fi

# ============================================
# Check 3: Configuration Files
# ============================================
echo -e "${YELLOW}[3/8]${NC} Checking configuration files..."
if [ -f "Podfile" ]; then
  echo -e "${GREEN}✅${NC} Podfile found"
else
  echo -e "${RED}❌${NC} Podfile NOT found"
  ISSUES=$((ISSUES + 1))
fi

if [ -f "myfortune/Info.plist" ]; then
  echo -e "${GREEN}✅${NC} Info.plist found"
else
  echo -e "${RED}❌${NC} Info.plist NOT found"
  ISSUES=$((ISSUES + 1))
fi

# ============================================
# Check 4: Resources
# ============================================
echo -e "${YELLOW}[4/8]${NC} Checking resources..."
if [ -d "myfortune/Resources/Assets.xcassets" ]; then
  echo -e "${GREEN}✅${NC} Assets.xcassets found"
else
  echo -e "${RED}❌${NC} Assets.xcassets NOT found"
  ISSUES=$((ISSUES + 1))
fi

# ============================================
# Check 5: Build Scripts
# ============================================
echo -e "${YELLOW}[5/8]${NC} Checking build scripts..."
for script in setup.sh build.sh test.sh; do
  if [ -x "$script" ]; then
    echo -e "${GREEN}✅${NC} $script is executable"
  else
    echo -e "${RED}❌${NC} $script is NOT executable"
    chmod +x "$script" 2>/dev/null && echo -e "${GREEN}✅${NC} Fixed: Made $script executable" && FIXES=$((FIXES + 1))
  fi
done

# ============================================
# Check 6: Git Status
# ============================================
echo -e "${YELLOW}[6/8]${NC} Checking git status..."
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${GREEN}✅${NC} Git repository found"
  UNCOMMITTED=$(git status --porcelain | wc -l)
  if [ "$UNCOMMITTED" -gt 0 ]; then
    echo -e "${YELLOW}⚠️ ${NC} $UNCOMMITTED files with uncommitted changes"
  else
    echo -e "${GREEN}✅${NC} All changes committed"
  fi
else
  echo -e "${RED}❌${NC} Not a git repository"
  ISSUES=$((ISSUES + 1))
fi

# ============================================
# Check 7: Dependencies
# ============================================
echo -e "${YELLOW}[7/8]${NC} Checking dependencies..."
if [ -f "Podfile.lock" ]; then
  echo -e "${GREEN}✅${NC} Podfile.lock found (dependencies installed)"
else
  echo -e "${YELLOW}⚠️ ${NC} Podfile.lock NOT found (dependencies not installed)"
  echo "    Run './setup.sh' on macOS to install"
fi

# ============================================
# Check 8: GitHub Actions
# ============================================
echo -e "${YELLOW}[8/8]${NC} Checking GitHub Actions..."
WORKFLOWS=$(ls -1 .github/workflows/*.yml 2>/dev/null | wc -l)
if [ "$WORKFLOWS" -gt 0 ]; then
  echo -e "${GREEN}✅${NC} Found $WORKFLOWS GitHub Actions workflows"
else
  echo -e "${RED}❌${NC} No GitHub Actions workflows found"
  ISSUES=$((ISSUES + 1))
fi

# ============================================
# Summary
# ============================================
echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Verification Summary${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "Issues found: ${RED}$ISSUES${NC}"
echo -e "Issues fixed: ${GREEN}$FIXES${NC}"
echo ""

if [ "$ISSUES" -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed! Project is ready for build.${NC}"
  echo ""
  echo "Next steps on macOS:"
  echo "  1. ./setup.sh         # Install dependencies"
  echo "  2. open myfortune.xcworkspace  # Open in Xcode"
  echo "  3. Cmd + B            # Build"
  echo "  4. Cmd + R            # Run"
  echo ""
  exit 0
else
  echo -e "${RED}❌ Found $ISSUES issue(s). Please fix them.${NC}"
  echo ""
  exit 1
fi
