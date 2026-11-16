#!/system/bin/sh
# Se ejecuta EN la consola. Uso: bench.sh <paquete> <actividad> [segundos_de_espera]
PKG=$1; ACT=$2; SETTLE=${3:-25}

pids() { ps -A -o PID,NAME | grep -E " $PKG(:.*)?\$" | sed 's/^ *\([0-9]*\).*/\1/'; }
ticks() { t=0; for p in $(pids); do set -- $(cut -d' ' -f14,15 /proc/$p/stat 2>/dev/null); t=$((t + ${1:-0} + ${2:-0})); done; echo $t; }
mem() { dumpsys meminfo $PKG | grep "TOTAL PSS:" | sed 's/.*TOTAL PSS: *\([0-9]*\).*TOTAL RSS: *\([0-9]*\).*/\1 \2/'; }

am force-stop $PKG; sleep 2
START=$(am start -W -a android.intent.action.MAIN -c android.intent.category.HOME -n $PKG/$ACT | grep -E "TotalTime" | sed 's/[^0-9]//g')
echo "start_ms=$START"
sleep $SETTLE

# --- Reposo: 3 muestras de RAM y CPU durante 30 s ---
T0=$(ticks); S=$(date +%s)
set -- $(mem); echo "idle_pss_1=$1"; echo "idle_rss_1=$2"; sleep 10
set -- $(mem); echo "idle_pss_2=$1"; echo "idle_rss_2=$2"; sleep 10
set -- $(mem); echo "idle_pss_3=$1"; echo "idle_rss_3=$2"; sleep 5
T1=$(ticks); E=$(date +%s)
echo "idle_cpu_ticks=$((T1 - T0))"; echo "idle_cpu_secs=$((E - S))"

# --- Navegación con el mando: 20 pulsaciones derecha + 20 izquierda ---
dumpsys gfxinfo $PKG reset >/dev/null
T0=$(ticks); S=$(date +%s)
i=0; while [ $i -lt 20 ]; do input keyevent 22; i=$((i + 1)); done
i=0; while [ $i -lt 20 ]; do input keyevent 21; i=$((i + 1)); done
sleep 2
T1=$(ticks); E=$(date +%s)
echo "nav_cpu_ticks=$((T1 - T0))"; echo "nav_cpu_secs=$((E - S))"
set -- $(mem); echo "nav_pss=$1"; echo "nav_rss=$2"
dumpsys gfxinfo $PKG | grep -E "Total frames rendered|Janky frames:|50th percentile|90th percentile|95th percentile|99th percentile|50th gpu|90th gpu|95th gpu|99th gpu" | sed 's/^ *//; s/: */=/'

# --- Desglose de memoria (KB) ---
dumpsys meminfo $PKG | grep -E "^ +(Java Heap|Native Heap|Graphics|Code|Stack|Private Other|System):" | sed 's/^ *//; s/: */=/; s/=\([0-9]*\).*/=\1/' | head -8
am force-stop $PKG
