# On-device E-Manafa

Profiles runtime and energy on Android devices without requiring using the original python tool and, eventually, an ADB connection. It can be invoked via command-line from a workstation connected to the device or from the device itself. 

Note: It does not support on-device results analysis. The results files must be exported to a workstation and analyzed with the python version (manafa -d <results_dir>).

## Requirements

- *Nix-based OS;
- Android SDK tools (adb);
- E-Manafa (for analyzing and generating the results).

## Installation

### From the workstation

```
$ ./manafa.sh install
```

## Usage

### From the workstation

```
$ ./manafa.sh start
$ ./manafa.sh stop
$ ./manafa.sh export
$ ./manafa.sh analyze
```

### From the device

```
$ sh manafa.sh start
$ sh manafa.sh stop
```
