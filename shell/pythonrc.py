# -*- coding: utf-8 -*-

"""My Pythonrc."""

import os
import sys
import re
import threading
import time
import readline
import atexit
import pprint
from tempfile import mkstemp
from code import InteractiveConsole

VIRTUAL_ENV = os.environ.get('VIRTUAL_ENV', None)
HOME = VIRTUAL_ENV or os.environ.get('WORKON_HOME', None) or os.environ['HOME']


class TermColors(dict):
    """Gives easy access to ANSI color codes."""

    COLOR_TEMPLATES = (
        ("Black", "0;30"),
        ("Red", "0;31"),
        ("Green", "0;32"),
        ("Brown", "0;33"),
        ("Blue", "0;34"),
        ("Purple", "0;35"),
        ("Cyan", "0;36"),
        ("LightGray", "0;37"),
        ("DarkGray", "1;30"),
        ("LightRed", "1;31"),
        ("LightGreen", "1;32"),
        ("Yellow", "1;33"),
        ("LightBlue", "1;34"),
        ("LightPurple", "1;35"),
        ("LightCyan", "1;36"),
        ("White", "1;37"),
        ("Normal", "0"),
    )

    NoColor = ''

    _base = '\001\033[%sm\002'

    def __init__(self):
        """Init colors based on terminal type."""
        super().__init__()
        if os.environ.get('TERM') in ('xterm-color', 'xterm-256color', 'linux',
                                      'screen', 'screen-256color', 'screen-bce'):
            self.update({k: self._base % v for k, v in self.COLOR_TEMPLATES})
        else:
            self.update({k: self.NoColor for k, _ in self.COLOR_TEMPLATES})


class EditableBufferInteractiveConsole(InteractiveConsole):
    """Gives an vim editable buffer to run commands in the python interactive console."""

    EDIT_CMD = '\\e'
    EDITOR = os.environ.get('EDITOR', 'vim')

    def __init__(self, *args, **kwargs):
        """Intialize a new interactive console."""
        self.last_buffer = []  # This holds the last executed statement
        InteractiveConsole.__init__(self, *args, **kwargs)

    def runsource(self, source, *args):
        """Run the last command."""
        self.last_buffer = [source.encode('utf-8')]
        return InteractiveConsole.runsource(self, source, *args)

    def raw_input(self, *args):
        r"""Launch editor when the \\e command is entered."""
        line = InteractiveConsole.raw_input(self, *args)
        if line == self.EDIT_CMD:
            fd, tmpfl = mkstemp('.py')
            os.write(fd, b'\n'.join(self.last_buffer))
            os.close(fd)
            os.system('%s %s' % (self.EDITOR, tmpfl))
            line = open(tmpfl).read()
            os.unlink(tmpfl)
            tmpfl = ''
            lines = line.split('\n')
            for i in range(len(lines) - 1):
                self.push(lines[i])
            line = lines[-1]
        return line


def my_displayhook(value):
    """Pretty print values."""
    if value is not None:
        try:
            import __builtin__
            __builtin__._ = value
        except ImportError:
            __builtins__._ = value
        import pprint
        pprint.pprint(value)
        del pprint


def my_exceptionhook(type, value, tb):
    """Pretty print exceptions."""
    sys.stderr.write(_c['Yellow'])
    import traceback
    traceback.print_exception(type, value, tb)
    del traceback
    sys.stderr.write(_c['Normal'])


# Save and restore history states
try:
    import readline
except ImportError:
    pass
else:
    # Setup tab completion
    try:
        import rlcompleter
    except ImportError:
        pass
    else:
        if 'libedit' in readline.__doc__:
            readline.parse_and_bind("bind ^I rl_complete")
        else:
            readline.parse_and_bind("tab: complete")

    # Setup hisory
    HISTFILE = os.path.join(HOME, ".pyhistory")
    if os.path.exists(HISTFILE):
        try:
            readline.read_history_file(HISTFILE)
        except:
            os.remove(HISTFILE)
    readline.set_history_length(256)
    atexit.register(lambda: readline.write_history_file(HISTFILE))

# Colorful prompt and pretty output
_c = TermColors()
sys.ps1 = '%s>>> %s' % (_c['Green'], _c['Normal'])
sys.ps2 = '%s... %s' % (_c['Red'], _c['Normal'])
sys.displayhook = my_displayhook
sys.excepthook = my_exceptionhook

# Start console
c = EditableBufferInteractiveConsole(locals=locals())
atexit.register(lambda: sys.stdout.write(
    "%(DarkGray)s Exiting python. %(Normal)s" % _c))
c.interact(banner="%(Brown)s Type \\e to get an external editor. %(Normal)s\n" % _c)
sys.exit()
