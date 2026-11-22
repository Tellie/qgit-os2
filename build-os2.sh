#!/bin/sh
# ------------------------------------------------------------------
#  build-os2.sh  -  qgit bouwen op OS/2 (ArcaOS) met Qt5 of Qt 6.8.3
#
#  Gebruik:   sh build-os2.sh [qt5|qt6] [stap]
#     qt5   = Qt 5.15.2 uit RPM (standaard)
#     qt6   = Qt 6.8.3 in h:/usr/qt6-683 (heeft Core5Compat nodig)
#     stap  = all (standaard) | configure | build | install | clean
#
#  Instelbaar via omgevingsvariabelen:
#     QT5_PREFIX   prefix van Qt5         (standaard leeg: CMake zoekt zelf)
#     QT6_PREFIX   prefix van Qt6         (standaard h:/usr/qt6-683)
#     PREFIX       installatiemap         (standaard ./dist-qt5 of ./dist-qt6)
#     JOBS         parallelle jobs        (standaard 2)
#
#  In CMD.EXE: eerst "set JOBS=4" enz., daarna sh build-os2.sh.
#  Alleen POSIX-sh, geen bash-ismen.
# ------------------------------------------------------------------

QTVER=${1:-qt5}
STEP=${2:-all}

case "$QTVER" in
    qt5|Qt5) QTVER=qt5; QT_PACKAGE=Qt5; QT_PREFIX=${QT5_PREFIX:-} ;;
    qt6|Qt6) QTVER=qt6; QT_PACKAGE=Qt6; QT_PREFIX=${QT6_PREFIX:-h:/usr/qt6-683} ;;
    all|configure|build|install|clean)
             STEP=$QTVER; QTVER=qt5; QT_PACKAGE=Qt5; QT_PREFIX=${QT5_PREFIX:-} ;;
    *)       echo "Gebruik: sh build-os2.sh [qt5|qt6] [all|configure|build|install|clean]"
             exit 1 ;;
esac

SRCDIR=$(pwd)
BUILDDIR=build-$QTVER
PREFIX=${PREFIX:-$SRCDIR/dist-$QTVER}
JOBS=${JOBS:-2}
LOG=$SRCDIR/build-os2-$QTVER.log

# ------------------------------------------------------------------
#  Kleuren
# ------------------------------------------------------------------
ESC=$(printf '\033')
RESET="${ESC}[0m"; RED="${ESC}[1;31m"; GREEN="${ESC}[1;32m"
YELLOW="${ESC}[1;33m"; CYAN="${ESC}[1;36m"; GREY="${ESC}[0;37m"

say()  { printf '%s==>%s %s\n' "$CYAN" "$RESET" "$*"; printf '==> %s\n' "$*" >> "$LOG"; }
ok()   { printf '  %sOK%s        %s\n' "$GREEN" "$RESET" "$*"; }
warn() { printf '  %sLET OP%s    %s\n' "$YELLOW" "$RESET" "$*"; printf 'LET OP: %s\n' "$*" >> "$LOG"; }
die()  { printf '%s*** FOUT:%s %s\n' "$RED" "$RESET" "$*"; printf '*** FOUT: %s\n' "$*" >> "$LOG"; exit 1; }
have() { command -v "$1" >/dev/null 2>&1; }

run() {
    printf '%s    $ %s%s\n' "$GREY" "$*" "$RESET"
    printf '$ %s\n' "$*" >> "$LOG"
    "$@" >> "$LOG" 2>&1
    rc=$?
    if [ $rc -ne 0 ]; then
        printf '%s--- foutregels uit %s ---%s\n' "$YELLOW" "$LOG" "$RESET"
        grep -n -E "error|Error|undefined reference|No such file|not found" "$LOG" \
            | tail -n 20
        die "'$1' stopte met code $rc (volledige uitvoer: $LOG)"
    fi
}

# Backslashes -> forward slashes (sh/CMake gaan stuk op h:\usr\bin\...)
fwd() { printf '%s\n' "$1" | tr '\\' /; }

# ------------------------------------------------------------------
#  Omgeving controleren
# ------------------------------------------------------------------
check_env() {
    [ -f "$SRCDIR/CMakeLists.txt" ] && [ -f "$SRCDIR/src/qgit.cpp" ] \
        || die "draai dit script in de qgit-os2-map"

    printf '\n%sqgit voor OS/2 - %s%s\n\n' "$CYAN" "$QT_PACKAGE" "$RESET"
    printf '%s--- Controle ---%s\n' "$CYAN" "$RESET"

    have cmake || die "cmake niet gevonden in PATH"
    ok "cmake      $(cmake --version | head -n 1)"

    CC=$(fwd "${CC:-gcc}"); CXX=$(fwd "${CXX:-g++}")
    export CC CXX
    have "$CXX" || [ -f "$CXX" ] || die "C++-compiler '$CXX' niet gevonden"
    ok "compiler   $($CXX --version | head -n 1)"

    have make || die "make niet gevonden in PATH"
    ok "make       $(make --version | head -n 1)"

    if [ "$QTVER" = qt6 ]; then
        [ -d "$QT_PREFIX/lib/cmake/Qt6" ] \
            || die "Qt6 niet gevonden in $QT_PREFIX (zet QT6_PREFIX)"
        ok "Qt6        $QT_PREFIX"
        if [ -d "$QT_PREFIX/lib/cmake/Qt6Core5Compat" ]; then
            ok "Core5Compat aanwezig"
        else
            die "Qt6Core5Compat ontbreekt in $QT_PREFIX; bouw eerst qt5compat 6.8.3, of gebruik: sh build-os2.sh qt5"
        fi
    else
        if [ -n "$QT_PREFIX" ]; then
            ok "Qt5        $QT_PREFIX"
        else
            ok "Qt5        (CMake zoekt zelf, bv. /@unixroot/usr)"
        fi
    fi

    if have git; then
        ok "git        $(git --version)"
    else
        warn "git niet gevonden; qgit heeft git nodig om te draaien"
    fi
    have source-highlight || warn "source-highlight niet gevonden (alleen syntaxkleuring, optioneel)"
    echo
}

# ------------------------------------------------------------------
#  Stappen
# ------------------------------------------------------------------
step_configure() {
    say "configure ($QT_PACKAGE) in $BUILDDIR"
    set -- -S "$SRCDIR" -B "$BUILDDIR" -G "Unix Makefiles" \
        -DCMAKE_BUILD_TYPE=Release \
        -DQT_PACKAGE="$QT_PACKAGE" \
        -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DCMAKE_C_COMPILER="$CC" -DCMAKE_CXX_COMPILER="$CXX"
    [ -n "$QT_PREFIX" ] && set -- "$@" -DCMAKE_PREFIX_PATH="$QT_PREFIX"
    run cmake "$@"
}

step_build() {
    [ -f "$BUILDDIR/CMakeCache.txt" ] || step_configure
    say "build ($JOBS jobs)"
    run cmake --build "$BUILDDIR" -j "$JOBS"
    exe="$BUILDDIR/qgit.exe"
    [ -f "$exe" ] || die "build klaar, maar $exe ontbreekt"
    size=$(ls -l "$exe" | awk '{print $5}')
    ok "qgit.exe   $exe ($size bytes)"
}

step_install() {
    [ -f "$BUILDDIR/qgit.exe" ] || step_build
    say "install naar $PREFIX"
    run cmake --install "$BUILDDIR"
    # OS/2-documentatie mee in de installatiemap
    [ -f "$SRCDIR/README-OS2.txt" ] && cp "$SRCDIR/README-OS2.txt" "$PREFIX/"
    ok "geinstalleerd in $PREFIX"
}

step_clean() {
    say "opruimen: $BUILDDIR"
    rm -rf "$BUILDDIR"
    ok "verwijderd"
}

# ------------------------------------------------------------------
: > "$LOG"
check_env

case "$STEP" in
    configure) step_configure ;;
    build)     step_build ;;
    install)   step_install ;;
    clean)     step_clean ;;
    all)       step_configure; step_build; step_install ;;
    *)         die "onbekende stap '$STEP' (all|configure|build|install|clean)" ;;
esac

printf '\n%sKlaar!%s qgit (%s) - uitvoer in %s\n\n' "$GREEN" "$RESET" "$QT_PACKAGE" "$LOG"
