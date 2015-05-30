# -*- coding: iso-8859-1 -*-
# Copyright (C) 2001,2002 Python Software Foundation
# csv package unit tests

import sys
import unittest
from StringIO import StringIO
import csv
import gc
from test import test_support

class Test_Csv(unittest.TestCase):
    """
    Test the underlying C csv parser in ways that are not appropriate
    from the high level interface. Further tests of this nature are done
    in TestDialectRegistry.
    """
    def test_reader_arg_valid(self):
        self.assertRaises(TypeError, csv.reader)
        self.assertRaises(TypeError, csv.reader, None)
        self.assertRaises(AttributeError, csv.reader, [], bad_attr = 0)
        self.assertRaises(csv.Error, csv.reader, [], 'foo')
        class BadClass:
            def __init__(self):
                raise IOError
        self.assertRaises(IOError, csv.reader, [], BadClass)
        self.assertRaises(TypeError, csv.reader, [], None)
        class BadDialect:
            bad_attr = 0
        self.assertRaises(AttributeError, csv.reader, [], BadDialect)

    def test_writer_arg_valid(self):
        self.assertRaises(TypeError, csv.writer)
        self.assertRaises(TypeError, csv.writer, None)
        self.assertRaises(AttributeError, csv.writer, StringIO(), bad_attr = 0)

    def _test_attrs(self, obj):
        self.assertEqual(obj.dialect.delimiter, ',')
        obj.dialect.delimiter = '\t'
        self.assertEqual(obj.dialect.delimiter, '\t')
        self.assertRaises(TypeError, delattr, obj.dialect, 'delimiter')
        self.assertRaises(TypeError, setattr, obj.dialect,
                          'lineterminator', None)
        obj.dialect.escapechar = None
        self.assertEqual(obj.dialect.escapechar, None)
        self.assertRaises(TypeError, delattr, obj.dialect, 'quoting')
        self.assertRaises(TypeError, setattr, obj.dialect, 'quoting', None)
        obj.dialect.quoting = csv.QUOTE_MINIMAL
        self.assertEqual(obj.dialect.quoting, csv.QUOTE_MINIMAL)

    def test_reader_attrs(self):
        self._test_attrs(csv.reader([]))

    def test_writer_attrs(self):
        self._test_attrs(csv.writer(StringIO()))

    def _write_test(self, fields, expect, **kwargs):
        fileobj = StringIO()
        writer = csv.writer(fileobj, **kwargs)
        writer.writerow(fields)
        self.assertEqual(fileobj.getvalue(),
                         expect + writer.dialect.lineterminator)

    def test_write_arg_valid(self):
        self.assertRaises(csv.Error, self._write_test, None, '')
        self._write_test((), '')
        self._write_test([None], '""')
        self.assertRaises(csv.Error, self._write_test,
                          [None], None, quoting = csv.QUOTE_NONE)
        # Check that exceptions are passed up the chain
        class BadList:
            def __len__(self):
                return 10;
            def __getitem__(self, i):
                if i > 2:
                    raise IOError
        self.assertRaises(IOError, self._write_test, BadList(), '')
        class BadItem:
            def __str__(self):
                raise IOError
        self.assertRaises(IOError, self._write_test, [BadItem()], '')

    def test_write_bigfield(self):
        # This exercises the buffer realloc functionality
        bigstring = 'X' * 50000
        self._write_test([bigstring,bigstring], '%s,%s' % \
                         (bigstring, bigstring))

    def test_write_quoting(self):
        self._write_test(['a','1','p,q'], 'a,1,"p,q"')
        self.assertRaises(csv.Error,
                          self._write_test,
                          ['a','1','p,q'], 'a,1,"p,q"',
                          quoting = csv.QUOTE_NONE)
        self._write_test(['a','1','p,q'], 'a,1,"p,q"',
                         quoting = csv.QUOTE_MINIMAL)
        self._write_test(['a','1','p,q'], '"a",1,"p,q"',
                         quoting = csv.QUOTE_NONNUMERIC)
        self._write_test(['a','1','p,q'], '"a","1","p,q"',
                         quoting = csv.QUOTE_ALL)

    def test_write_escape(self):
        self._write_test(['a','1','p,q'], 'a,1,"p,q"',
                         escapechar='\\')
# FAILED - needs to be fixed [am]:
#        self._write_test(['a','1','p,"q"'], 'a,1,"p,\\"q\\"',
#                         escapechar='\\', doublequote = 0)
        self._write_test(['a','1','p,q'], 'a,1,p\\,q',
                         escapechar='\\', quoting = csv.QUOTE_NONE)

    def test_writerows(self):
        class BrokenFile:
            def write(self, buf):
                raise IOError
        writer = csv.writer(BrokenFile())
        self.assertRaises(IOError, writer.writerows, [['a']])
        fileobj = StringIO()
        writer = csv.writer(fileobj)
        self.assertRaises(TypeError, writer.writerows, None)
        writer.writerows([['a','b'],['c','d']])
        self.assertEqual(fileobj.getvalue(), "a,b\r\nc,d\r\n")

    def _read_test(self, input, expect, **kwargs):
        reader = csv.reader(input, **kwargs)
        result = list(reader)
        self.assertEqual(result, expect)

    def test_read_oddinputs(self):
        self._read_test([], [])
        self._read_test([''], [[]])
        self.assertRaises(csv.Error, self._read_test,
                          ['"ab"c'], None, strict = 1)
        # cannot handle null bytes for the moment
        self.assertRaises(csv.Error, self._read_test,
                          ['ab\0c'], None, strict = 1)
        self._read_test(['"ab"c'], [['abc']], doublequote = 0)

    def test_read_eol(self):
        self._read_test(['a,b'], [['a','b']])
        self._read_test(['a,b\n'], [['a','b']])
        self._read_test(['a,b\r\n'], [['a','b']])
        self._read_test(['a,b\r'], [['a','b']])
        self.assertRaises(csv.Error, self._read_test, ['a,b\rc,d'], [])
        self.assertRaises(csv.Error, self._read_test, ['a,b\nc,d'], [])
        self.assertRaises(csv.Error, self._read_test, ['a,b\r\nc,d'], [])

    def test_read_escape(self):
        self._read_test(['a,\\b,c'], [['a', '\\b', 'c']], escapechar='\\')
        self._read_test(['a,b\\,c'], [['a', 'b,c']], escapechar='\\')
        self._read_test(['a,"b\\,c"'], [['a', 'b,c']], escapechar='\\')
        self._read_test(['a,"b,\\c"'], [['a', 'b,\\c']], escapechar='\\')
        self._read_test(['a,"b,c\\""'], [['a', 'b,c"']], escapechar='\\')
        self._read_test(['a,"b,c"\\'], [['a', 'b,c\\']], escapechar='\\')

    def test_read_bigfield(self):
        # This exercises the buffer realloc functionality
        bigstring = 'X' * 50000
        bigline = '%s,%s' % (bigstring, bigstring)
        self._read_test([bigline], [[bigstring, bigstring]])

class TestDialectRegistry(unittest.TestCase):
    def test_registry_badargs(self):
        self.assertRaises(TypeError, csv.list_dialects, None)
        self.assertRaises(TypeError, csv.get_dialect)
        self.assertRaises(csv.Error, csv.get_dialect, None)
        self.assertRaises(csv.Error, csv.get_dialect, "nonesuch")
        self.assertRaises(TypeError, csv.unregister_dialect)
        self.assertRaises(csv.Error, csv.unregister_dialect, None)
        self.assertRaises(csv.Error, csv.unregister_dialect, "nonesuch")
        self.assertRaises(TypeError, csv.register_dialect, None)
        self.assertRaises(TypeError, csv.register_dialect, None, None)
        self.assertRaises(TypeError, csv.register_dialect, "nonesuch", None)
        class bogus:
            def __init__(self):
                raise KeyError
        self.assertRaises(KeyError, csv.register_dialect, "nonesuch", bogus)

    def test_registry(self):
        class myexceltsv(csv.excel):
            delimiter = "\t"
        name = "myexceltsv"
        expected_dialects = csv.list_dialects() + [name]
        expected_dialects.sort()
        csv.register_dialect(name, myexceltsv)
        try:
            self.failUnless(isinstance(csv.get_dialect(name), myexceltsv))
            got_dialects = csv.list_dialects()
            got_dialects.sort()
            self.assertEqual(expected_dialects, got_dialects)
        finally:
            csv.unregister_dialect(name)

    def test_incomplete_dialect(self):
        class myexceltsv(csv.Dialect):
            delimiter = "\t"
        self.assertRaises(csv.Error, myexceltsv)

    def test_space_dialect(self):
        class space(csv.excel):
            delimiter = " "
            quoting = csv.QUOTE_NONE
            escapechar = "\\"

        s = StringIO("abc def\nc1ccccc1 benzene\n")
        rdr = csv.reader(s, dialect=space())
        self.assertEqual(rdr.next(), ["abc", "def"])
        self.assertEqual(rdr.next(), ["c1ccccc1", "benzene"])

    def test_dialect_apply(self):
        class testA(csv.excel):
            delimiter = "\t"
        class testB(csv.excel):
            delimiter = ":"
        class testC(csv.excel):
            delimiter = "|"

        csv.register_dialect('testC', testC)
        try:
            fileobj = StringIO()
            writer = csv.writer(fileobj)
            writer.writerow([1,2,3])
            self.assertEqual(fileobj.getvalue(), "1,2,3\r\n")

            fileobj = StringIO()
            writer = csv.writer(fileobj, testA)
            writer.writerow([1,2,3])
            self.assertEqual(fileobj.getvalue(), "1\t2\t3\r\n")

            fileobj = StringIO()
            writer = csv.writer(fileobj, dialect=testB())
            writer.writerow([1,2,3])
            self.assertEqual(fileobj.getvalue(), "1:2:3\r\n")

            fileobj = StringIO()
            writer = csv.writer(fileobj, dialect='testC')
            writer.writerow([1,2,3])
            self.assertEqual(fileobj.getvalue(), "1|2|3\r\n")

            fileobj = StringIO()
            writer = csv.writer(fileobj, dialect=testA, delimiter=';')
            writer.writerow([1,2,3])
            self.assertEqual(fileobj.getvalue(), "1;2;3\r\n")
        finally:
            csv.unregister_dialect('testC')

    def test_bad_dialect(self):
        # Unknown parameter
        self.assertRaises(AttributeError, csv.reader, [], bad_attr = 0)
        # Bad values
        self.assertRaises(TypeError, csv.reader, [], delimiter = None)
        self.assertRaises(TypeError, csv.reader, [], quoting = -1)
        self.assertRaises(TypeError, csv.reader, [], quoting = 100)

class TestCsvBase(unittest.TestCase):
    def readerAssertEqual(self, input, expected_result):
        reader = csv.reader(StringIO(input), dialect = self.dialect)
        fields = list(reader)
        self.assertEqual(fields, expected_result)

    def writerAssertEqual(self, input, expected_result):
        fileobj = StringIO()
        writer = csv.writer(fileobj, dialect = self.dialect)
        writer.writerows(input)
        self.assertEqual(fileobj.getvalue(), expected_result)

class TestDialectExcel(TestCsvBase):
    dialect = 'excel'

    def test_single(self):
        self.readerAssertEqual('abc', [['abc']])

    def test_simple(self):
        self.readerAssertEqual('1,2,3,4,5', [['1','2','3','4','5']])

    def test_blankline(self):
        self.readerAssertEqual('', [])

    def test_empty_fields(self):
        self.readerAssertEqual(',', [['', '']])

    def test_singlequoted(self):
        self.readerAssertEqual('""', [['']])

    def test_singlequoted_left_empty(self):
        self.readerAssertEqual('"",', [['','']])

    def test_singlequoted_right_empty(self):
        self.readerAssertEqual(',""', [['','']])

    def test_single_quoted_quote(self):
        self.readerAssertEqual('""""', [['"']])

    def test_quoted_quotes(self):
        self.readerAssertEqual('""""""', [['""']])

    def test_inline_quote(self):
        self.readerAssertEqual('a""b', [['a""b']])

    def test_inline_quotes(self):
        self.readerAssertEqual('a"b"c', [['a"b"c']])

    def test_quotes_and_more(self):
        self.readerAssertEqual('"a"b', [['ab']])

    def test_lone_quote(self):
        self.readerAssertEqual('a"b', [['a"b']])

    def test_quote_and_quote(self):
        self.readerAssertEqual('"a" "b"', [['a "b"']])

    def test_space_and_quote(self):
        self.readerAssertEqual(' "a"', [[' "a"']])

    def test_quoted(self):
        self.readerAssertEqual('1,2,3,"I think, therefore I am",5,6',
                               [['1', '2', '3',
                                 'I think, therefore I am',
                                 '5', '6']])

    def test_quoted_quote(self):
        self.readerAssertEqual('1,2,3,"""I see,"" said the blind man","as he picked up his hammer and saw"',
                               [['1', '2', '3',
                                 '"I see," said the blind man',
                                 'as he picked up his hammer and saw']])

    def test_quoted_nl(self):
        input = '''\
1,2,3,"""I see,""
said the blind man","as he picked up his
hammer and saw"
9,8,7,6'''
        self.readerAssertEqual(input,
                               [['1', '2', '3',
                                   '"I see,"\nsaid the blind man',
                                   'as he picked up his\nhammer and saw'],
                                ['9','8','7','6']])

    def test_dubious_quote(self):
        self.readerAssertEqual('12,12,1",', [['12', '12', '1"', '']])

    def test_null(self):
        self.writerAssertEqual([], '')

    def test_single(self):
        self.writerAssertEqual([['abc']], 'abc\r\n')

    def test_simple(self):
        self.writerAssertEqual([[1, 2, 'abc', 3, 4]], '1,2,abc,3,4\r\n')

    def test_quotes(self):
        self.writerAssertEqual([[1, 2, 'a"bc"', 3, 4]], '1,2,"a""bc""",3,4\r\n')

    def test_quote_fieldsep(self):
        self.writerAssertEqual([['abc,def']], '"abc,def"\r\n')

    def test_newlines(self):
        self.writerAssertEqual([[1, 2, 'a\nbc', 3, 4]], '1,2,"a\nbc",3,4\r\n')

class EscapedExcel(csv.excel):
    quoting = csv.QUOTE_NONE
    escapechar = '\\'

class TestEscapedExcel(TestCsvBase):
    dialect = EscapedExcel()

    def test_escape_fieldsep(self):
        self.writerAssertEqual([['abc,def']], 'abc\\,def\r\n')

    def test_read_escape_fieldsep(self):
        self.readerAssertEqual('abc\\,def\r\n', [['abc,def']])

class QuotedEscapedExcel(csv.excel):
    quoting = csv.QUOTE_NONNUMERIC
    escapechar = '\\'

class TestQuotedEscapedExcel(TestCsvBase):
    dialect = QuotedEscapedExcel()

    def test_write_escape_fieldsep(self):
        self.writerAssertEqual([['abc,def']], '"abc,def"\r\n')

    def test_read_escape_fieldsep(self):
        self.readerAssertEqual('"abc\\,def"\r\n', [['abc,def']])

# Disabled, pending support in csv.utils module
class TestDictFields(unittest.TestCase):
    ### "long" means the row is longer than the number of fieldnames
    ### "short" means there are fewer elements in the row than fieldnames
    def test_write_simple_dict(self):
        fileobj = StringIO()
        writer = csv.DictWriter(fileobj, fieldnames = ["f1", "f2", "f3"])
        writer.writerow({"f1": 10, "f3": "abc"})
        self.assertEqual(fileobj.getvalue(), "10,,abc\r\n")

    def test_write_no_fields(self):
        fileobj = StringIO()
        self.assertRaises(TypeError, csv.DictWriter, fileobj)

    def test_read_dict_fields(self):
        reader = csv.DictReader(StringIO("1,2,abc\r\n"),
                                fieldnames=["f1", "f2", "f3"])
        self.assertEqual(reader.next(), {"f1": '1', "f2": '2', "f3": 'abc'})

    def test_read_long(self):
        reader = csv.DictReader(StringIO("1,2,abc,4,5,6\r\n"),
                                fieldnames=["f1", "f2"])
        self.assertEqual(reader.next(), {"f1": '1', "f2": '2',
                                         None: ["abc", "4", "5", "6"]})

    def test_read_long_with_rest(self):
        reader = csv.DictReader(StringIO("1,2,abc,4,5,6\r\n"),
                                fieldnames=["f1", "f2"], restkey="_rest")
        self.assertEqual(reader.next(), {"f1": '1', "f2": '2',
                                         "_rest": ["abc", "4", "5", "6"]})

    def test_read_short(self):
        reader = csv.DictReader(["1,2,abc,4,5,6\r\n","1,2,abc\r\n"],
                                fieldnames="1 2 3 4 5 6".split(),
                                restval="DEFAULT")
        self.assertEqual(reader.next(), {"1": '1', "2": '2', "3": 'abc',
                                         "4": '4', "5": '5', "6": '6'})
        self.assertEqual(reader.next(), {"1": '1', "2": '2', "3": 'abc',
                                         "4": 'DEFAULT', "5": 'DEFAULT',
                                         "6": 'DEFAULT'})

    def test_read_multi(self):
        sample = [
            '2147483648,43.0e12,17,abc,def\r\n',
            '147483648,43.0e2,17,abc,def\r\n',
            '47483648,43.0,170,abc,def\r\n'
            ]

        reader = csv.DictReader(sample,
                                fieldnames="i1 float i2 s1 s2".split())
        self.assertEqual(reader.next(), {"i1": '2147483648',
                                         "float": '43.0e12',
                                         "i2": '17',
                                         "s1": 'abc',
                                         "s2": 'def'})

    def test_read_with_blanks(self):
        reader = csv.DictReader(["1,2,abc,4,5,6\r\n","\r\n",
                                 "1,2,abc,4,5,6\r\n"],
                                fieldnames="1 2 3 4 5 6".split())
        self.assertEqual(reader.next(), {"1": '1', "2": '2', "3": 'abc',
                                         "4": '4', "5": '5', "6": '6'})
        self.assertEqual(reader.next(), {"1": '1', "2": '2', "3": 'abc',
                                         "4": '4', "5": '5', "6": '6'})

    def test_read_semi_sep(self):
        reader = csv.DictReader(["1;2;abc;4;5;6\r\n"],
                                fieldnames="1 2 3 4 5 6".split(),
                                delimiter=';')
        self.assertEqual(reader.next(), {"1": '1', "2": '2', "3": 'abc',
                                         "4": '4', "5": '5', "6": '6'})

class TestArrayWrites(unittest.TestCase):
    def test_int_write(self):
        import array
        contents = [(20-i) for i in range(20)]
        a = array.array('i', contents)
        fileobj = StringIO()
        writer = csv.writer(fileobj, dialect="excel")
        writer.writerow(a)
        expected = ",".join([str(i) for i in a])+"\r\n"
        self.assertEqual(fileobj.getvalue(), expected)

    def test_double_write(self):
        import array
        contents = [(20-i)*0.1 for i in range(20)]
        a = array.array('d', contents)
        fileobj = StringIO()
        writer = csv.writer(fileobj, dialect="excel")
        writer.writerow(a)
        expected = ",".join([str(i) for i in a])+"\r\n"
        self.assertEqual(fileobj.getvalue(), expected)

    def test_float_write(self):
        import array
        contents = [(20-i)*0.1 for i in range(20)]
        a = array.array('f', contents)
        fileobj = StringIO()
        writer = csv.writer(fileobj, dialect="excel")
        writer.writerow(a)
        expected = ",".join([str(i) for i in a])+"\r\n"
        self.assertEqual(fileobj.getvalue(), expected)

    def test_char_write(self):
        import array, string
        a = array.array('c', string.letters)
        fileobj = StringIO()
        writer = csv.writer(fileobj, dialect="excel")
        writer.writerow(a)
        expected = ",".join(a)+"\r\n"
        self.assertEqual(fileobj.getvalue(), expected)

class TestDialectValidity(unittest.TestCase):
    def test_quoting(self):
        class mydialect(csv.Dialect):
            delimiter = ";"
            escapechar = '\\'
            doublequote = False
            skipinitialspace = True
            lineterminator = '\r\n'
            quoting = csv.QUOTE_NONE
        d = mydialect()

        mydialect.quoting = None
        self.assertRaises(csv.Error, mydialect)

        mydialect.quoting = csv.QUOTE_NONE
        mydialect.escapechar = None
        self.assertRaises(csv.Error, mydialect)

        mydialect.doublequote = True
        mydialect.quoting = csv.QUOTE_ALL
        mydialect.quotechar = '"'
        d = mydialect()

        mydialect.quotechar = "''"
        self.assertRaises(csv.Error, mydialect)

        mydialect.quotechar = 4
        self.assertRaises(csv.Error, mydialect)

    def test_delimiter(self):
        class mydialect(csv.Dialect):
            delimiter = ";"
            escapechar = '\\'
            doublequote = False
            skipinitialspace = True
            lineterminator = '\r\n'
            quoting = csv.QUOTE_NONE
        d = mydialect()

        mydialect.delimiter = ":::"
        self.assertRaises(csv.Error, mydialect)

        mydialect.delimiter = 4
        self.assertRaises(csv.Error, mydialect)

    def test_lineterminator(self):
        class mydialect(csv.Dialect):
            delimiter = ";"
            escapechar = '\\'
            doublequote = False
            skipinitialspace = True
            lineterminator = '\r\n'
            quoting = csv.QUOTE_NONE
        d = mydialect()

        mydialect.lineterminator = ":::"
        d = mydialect()

        mydialect.lineterminator = 4
        self.assertRaises(csv.Error, mydialect)


class TestSniffer(unittest.TestCase):
    sample1 = """\
Harry's, Arlington Heights, IL, 2/1/03, Kimi Hayes
Shark City, Glendale Heights, IL, 12/28/02, Prezence
Tommy's Place, Blue Island, IL, 12/28/02, Blue Sunday/White Crow
Stonecutters Seafood and Chop House, Lemont, IL, 12/19/02, Week Back
"""
    sample2 = """\
'Harry''s':'Arlington Heights':'IL':'2/1/03':'Kimi Hayes'
'Shark City':'Glendale Heights':'IL':'12/28/02':'Prezence'
'Tommy''s Place':'Blue Island':'IL':'12/28/02':'Blue Sunday/White Crow'
'Stonecutters Seafood and Chop House':'Lemont':'IL':'12/19/02':'Week Back'
"""

    header = '''\
"venue","city","state","date","performers"
'''
    sample3 = '''\
05/05/03?05/05/03?05/05/03?05/05/03?05/05/03?05/05/03
05/05/03?05/05/03?05/05/03?05/05/03?05/05/03?05/05/03
05/05/03?05/05/03?05/05/03?05/05/03?05/05/03?05/05/03
'''

    sample4 = '''\
2147483648;43.0e12;17;abc;def
147483648;43.0e2;17;abc;def
47483648;43.0;170;abc;def
'''

    def test_has_header(self):
        sniffer = csv.Sniffer()
        self.assertEqual(sniffer.has_header(self.sample1), False)
        self.assertEqual(sniffer.has_header(self.header+self.sample1), True)

    def test_sniff(self):
        sniffer = csv.Sniffer()
        dialect = sniffer.sniff(self.sample1)
        self.assertEqual(dialect.delimiter, ",")
        self.assertEqual(dialect.quotechar, '"')
        self.assertEqual(dialect.skipinitialspace, True)

        dialect = sniffer.sniff(self.sample2)
        self.assertEqual(dialect.delimiter, ":")
        self.assertEqual(dialect.quotechar, "'")
        self.assertEqual(dialect.skipinitialspace, False)

    def test_delimiters(self):
        sniffer = csv.Sniffer()
        dialect = sniffer.sniff(self.sample3)
        self.assertEqual(dialect.delimiter, "0")
        dialect = sniffer.sniff(self.sample3, delimiters="?,")
        self.assertEqual(dialect.delimiter, "?")
        dialect = sniffer.sniff(self.sample3, delimiters="/,")
        self.assertEqual(dialect.delimiter, "/")
        dialect = sniffer.sniff(self.sample4)
        self.assertEqual(dialect.delimiter, ";")

if not hasattr(sys, "gettotalrefcount"):
    if test_support.verbose: print "*** skipping leakage tests ***"
else:
    class NUL:
        def write(s, *args):
            pass
        writelines = write

    class TestLeaks(unittest.TestCase):
        def test_create_read(self):
            delta = 0
            lastrc = sys.gettotalrefcount()
            for i in xrange(20):
                gc.collect()
                self.assertEqual(gc.garbage, [])
                rc = sys.gettotalrefcount()
                csv.reader(["a,b,c\r\n"])
                csv.reader(["a,b,c\r\n"])
                csv.reader(["a,b,c\r\n"])
                delta = rc-lastrc
                lastrc = rc
            # if csv.reader() leaks, last delta should be 3 or more
            self.assertEqual(delta < 3, True)

        def test_create_write(self):
            delta = 0
            lastrc = sys.gettotalrefcount()
            s = NUL()
            for i in xrange(20):
                gc.collect()
                self.assertEqual(gc.garbage, [])
                rc = sys.gettotalrefcount()
                csv.writer(s)
                csv.writer(s)
                csv.writer(s)
                delta = rc-lastrc
                lastrc = rc
            # if csv.writer() leaks, last delta should be 3 or more
            self.assertEqual(delta < 3, True)

        def test_read(self):
            delta = 0
            rows = ["a,b,c\r\n"]*5
            lastrc = sys.gettotalrefcount()
            for i in xrange(20):
                gc.collect()
                self.assertEqual(gc.garbage, [])
                rc = sys.gettotalrefcount()
                rdr = csv.reader(rows)
                for row in rdr:
                    pass
                delta = rc-lastrc
                lastrc = rc
            # if reader leaks during read, delta should be 5 or more
            self.assertEqual(delta < 5, True)

        def test_write(self):
            delta = 0
            rows = [[1,2,3]]*5
            s = NUL()
            lastrc = sys.gettotalrefcount()
            for i in xrange(20):
                gc.collect()
                self.assertEqual(gc.garbage, [])
                rc = sys.gettotalrefcount()
                writer = csv.writer(s)
                for row in rows:
                    writer.writerow(row)
                delta = rc-lastrc
                lastrc = rc
            # if writer leaks during write, last delta should be 5 or more
            self.assertEqual(delta < 5, True)

# commented out for now - csv module doesn't yet support Unicode
if 0:
    from StringIO import StringIO
    import csv

    class TestUnicode(unittest.TestCase):
        def test_unicode_read(self):
            import codecs
            f = codecs.EncodedFile(StringIO("Martin von L�wis,"
                                            "Marc Andr� Lemburg,"
                                            "Guido van Rossum,"
                                            "Fran�ois Pinard\r\n"),
                                   data_encoding='iso-8859-1')
            reader = csv.reader(f)
            self.assertEqual(list(reader), [[u"Martin von L�wis",
                                             u"Marc Andr� Lemburg",
                                             u"Guido van Rossum",
                                             u"Fran�ois Pinardn"]])

def test_main():
    mod = sys.modules[__name__]
    test_support.run_unittest(
        *[getattr(mod, name) for name in dir(mod) if name.startswith('Test')]
    )

if __name__ == '__main__':
    test_main()
