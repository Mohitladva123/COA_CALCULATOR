@echo off
setlocal

echo [1/2] Compiling Verilog sources...
iverilog -o sim.vvp rtl/*.v tb/calc_core_tb.v
if errorlevel 1 (
    echo Compile failed.
    exit /b 1
)

echo [2/2] Running simulation...
vvp sim.vvp
if errorlevel 1 (
    echo Simulation failed.
    exit /b 1
)

if exist wave.vcd (
    where gtkwave >nul 2>&1
    if %errorlevel%==0 (
        echo Opening waveform in GTKWave...
        start "" gtkwave wave.vcd
    ) else (
        echo GTKWave not found. Open wave.vcd manually if needed.
    )
)

echo Done.
exit /b 0
