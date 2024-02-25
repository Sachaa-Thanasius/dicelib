#   Copyright 2020-present Michael Hall
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

import pathlib
import sys

from cffi import FFI

ffi = FFI()
ffi.cdef(
    """
    double ev_xdy_keep_best_n(unsigned x, unsigned y, unsigned n);
    double ev_xdy_keep_worst_n(unsigned x, unsigned y, unsigned n);
    """,
)

# TODO: wheels, etc
base_bin_path = pathlib.Path(__file__).parent.joinpath("include")

if sys.platform == "win32":
    windows_path = str(base_bin_path.joinpath("win/x86_64/dicemath.dll").resolve())
    dicemath = ffi.dlopen(windows_path)
else:
    dicemath = ffi.dlopen("dicemath.dll")

ev_roll_keep_best = dicemath.ev_xdy_keep_best_n  # type: ignore
ev_roll_keep_worst = dicemath.ev_xdy_keep_worst_n  # type: ignore

__all__ = ["ev_roll_keep_best", "ev_roll_keep_worst"]
