# ----------------------------------------------------------------------
# |
# |  _custom_data.py
# |
# |  David Brownell <db@DavidBrownell.com>
# |      2019-05-12 17:40:46
# |
# ----------------------------------------------------------------------
# |
# |  Copyright David Brownell 2019-22
# |  Distributed under the Boost Software License, Version 1.0. See
# |  accompanying file LICENSE_1_0.txt or copy at
# |  http://www.boost.org/LICENSE_1_0.txt.
# |
# ----------------------------------------------------------------------
"""Data used by both Setup_custom.py and Activate_custom.py"""

import os

import CommonEnvironment

# ----------------------------------------------------------------------
_script_fullpath                            = CommonEnvironment.ThisFullpath()
_script_dir, _script_name                   = os.path.split(_script_fullpath)
# ----------------------------------------------------------------------

_CUSTOM_DATA                                = [
    (
        "GCC - 9.1.0",
        "f7dbc5a030c4aad5742c97687fa9fe53a16c66e3c9959f50be14c13114fa12f1",
        [
            "Tools",
            "gcc",
            "v9.1.0",
            "Linux",
        ],
    ),
]
