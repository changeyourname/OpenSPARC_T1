# Test some Unicode file name semantics
# We dont test many operations on files other than
# that their names can be used with Unicode characters.
import os, glob

from test.test_support import verify, TestSkipped, TESTFN_UNICODE
from test.test_support import TESTFN_ENCODING
try:
    TESTFN_ENCODED = TESTFN_UNICODE.encode(TESTFN_ENCODING)
except (UnicodeError, TypeError):
    # Either the file system encoding is None, or the file name
    # cannot be encoded in the file system encoding.
    raise TestSkipped("No Unicode filesystem semantics on this platform.")

# Check with creation as Unicode string.
f = open(TESTFN_UNICODE, 'wb')
if not os.path.isfile(TESTFN_UNICODE):
    print "File doesn't exist after creating it"

if not os.path.isfile(TESTFN_ENCODED):
    print "File doesn't exist (encoded string) after creating it"

f.close()

# Test stat and chmod
if os.stat(TESTFN_ENCODED) != os.stat(TESTFN_UNICODE):
    print "os.stat() did not agree on the 2 filenames"
if os.lstat(TESTFN_ENCODED) != os.lstat(TESTFN_UNICODE):
    print "os.lstat() did not agree on the 2 filenames"
os.chmod(TESTFN_ENCODED, 0777)
os.chmod(TESTFN_UNICODE, 0777)

# Test rename
try:
    os.unlink(TESTFN_ENCODED + ".new")
except os.error:
    pass
os.rename(TESTFN_ENCODED, TESTFN_ENCODED + ".new")
os.rename(TESTFN_UNICODE+".new", TESTFN_ENCODED)

os.unlink(TESTFN_ENCODED)
if os.path.isfile(TESTFN_ENCODED) or \
   os.path.isfile(TESTFN_UNICODE):
    print "File exists after deleting it"

# Check with creation as encoded string.
f = open(TESTFN_ENCODED, 'wb')
if not os.path.isfile(TESTFN_UNICODE) or \
   not os.path.isfile(TESTFN_ENCODED):
    print "File doesn't exist after creating it"

path, base = os.path.split(os.path.abspath(TESTFN_ENCODED))
# Until PEP 277 is adopted, this test is not portable
#  if base not in os.listdir(path):
#      print "Filename did not appear in os.listdir()"
#  path, base = os.path.split(os.path.abspath(TESTFN_UNICODE))
#  if base not in os.listdir(path):
#      print "Unicode filename did not appear in os.listdir()"

if os.path.abspath(TESTFN_ENCODED) != os.path.abspath(glob.glob(TESTFN_ENCODED)[0]):
    print "Filename did not appear in glob.glob()"
if os.path.abspath(TESTFN_UNICODE) != os.path.abspath(glob.glob(TESTFN_UNICODE)[0]):
    print "Unicode filename did not appear in glob.glob()"

f.close()
os.unlink(TESTFN_UNICODE)
if os.path.isfile(TESTFN_ENCODED) or \
   os.path.isfile(TESTFN_UNICODE):
    print "File exists after deleting it"

# test os.open
f = os.open(TESTFN_ENCODED, os.O_CREAT)
if not os.path.isfile(TESTFN_UNICODE) or \
   not os.path.isfile(TESTFN_ENCODED):
    print "File doesn't exist after creating it"
os.close(f)
os.unlink(TESTFN_UNICODE)

# Test directories etc
cwd = os.getcwd()
abs_encoded = os.path.abspath(TESTFN_ENCODED) + ".dir"
abs_unicode = os.path.abspath(TESTFN_UNICODE) + ".dir"
os.mkdir(abs_encoded)
try:
    os.chdir(abs_encoded)
    os.chdir(abs_unicode)
finally:
    os.chdir(cwd)
    os.rmdir(abs_unicode)
os.mkdir(abs_unicode)
try:
    os.chdir(abs_encoded)
    os.chdir(abs_unicode)
finally:
    os.chdir(cwd)
    os.rmdir(abs_encoded)
print "All the Unicode tests appeared to work"
