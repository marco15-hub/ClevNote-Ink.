<!-- coderabbit-ai-generated:v1 -->

# Bitwig Boost for Windows

Use this script in Git Bash on Windows while running Bitwig Studio. It temporarily switches Windows to its existing High Performance power plan, then restores the previous plan when you finish. This may improve performance, but it is not guaranteed and can increase power use and heat. It does not change Bitwig or plugin settings.

## Run it

1. Install Git for Windows if you do not already have Git Bash.
2. Open the folder containing `bitwig-boost.sh` in Git Bash.
3. Run `bash bitwig-boost.sh`.
4. Open Bitwig Studio and use it. After you close Bitwig, return to Git Bash and press Enter.

The script prints your previous plan and a command to restore it manually. Keep that command in case the computer or terminal stops unexpectedly. It leaves the current plan alone if you manually select a different plan during the session. If High Performance is unavailable, the script exits without changing the plan.

If you hear audio dropouts, try increasing the audio buffer in Bitwig's audio settings. A larger buffer increases latency. For details, see [Bitwig's audio settings guide](https://www.bitwig.com/userguide/latest/the_dashboard/#audio_settings) and [Microsoft's powercfg documentation](https://learn.microsoft.com/en-us/windows-hardware/design/device-experiences/powercfg-command-line-options).
