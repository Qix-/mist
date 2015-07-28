# Mist [![Travis-CI Build Status](https://travis-ci.org/AERO-ff/mist.svg?branch=master)](https://travis-ci.org/AERO-ff/mist) [![Coverage Status](https://coveralls.io/repos/AERO-ff/mist/badge.svg?branch=master)](https://coveralls.io/r/AERO-ff/mist?branch=master)
The build system for AERO.
Mist is a [Ninja](https://martine.github.io/ninja/) build system wrapper written
in Node.JS using a PEG.js parser.

It's as simple as that.

## Usage
<!-- don't remove the trailing spaces in the below block! -->

```docopt
Mist, a build system.

Usage:
  mist [build] [-C <cwd>] [-b <name>]
  mist render [-C <cwd>] [-b <name>] [-s | -o <file>]

Options:
  build                  Build the project [default]
  render                 Render the build configuration to a file
  
  -C, --cwd <cwd>        Specify working directory
  -b, --backend <name>   Specify the backend to use [default: ninja]
  -s, --stdout           Render to standard output
  -o, --out <file>       Render to file (defaults to backend configuration file)
```

## License
Mist is licensed under the [MIT License](http://opensource.org/licenses/MIT).
You can find a copy of it in [LICENSE](LICENSE).
