# BigClown IDE

VSCode + ARM GCC + utilities.
For SDK API documentation have a look at http://sdk.bigclown.com/
For whole BigClown documentation have a look at https://doc.bigclown.com/

## Build project

Press `Ctrl + Shift + B` or type `Ctrl + P` then `task build` then `<Enter>`.
Application is in `app\application.c`.

## Flash MCU via USB DFU

Connect Core Module via USB cable. Make CPU waiting for DFU (on Core Module press RESET button, press BOOT button, release RESET button, release BOOT button).

Type `Ctrl + P` then `task dfu` then `<Enter>`.

## Terminal on COM port

``Ctrl + ` `` (or `Ctrl + Shift + P to term <Enter>`) to open terminal window.

Type `serialport-list` then `<Enter>` to list available COM ports.

Type `serialport-term -p COM5` to start serial port terminal on COM5 (use appropriate COM port number). `Ctrl+C` to exit terminal.
