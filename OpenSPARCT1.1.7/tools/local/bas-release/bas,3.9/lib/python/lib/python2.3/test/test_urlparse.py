#! /usr/bin/env python

from test import test_support
import unittest
import urlparse

RFC1808_BASE = "http://a/b/c/d;p?q#f"
RFC2396_BASE = "http://a/b/c/d;p?q"

class UrlParseTestCase(unittest.TestCase):
    def test_frags(self):
        for url, parsed, split in [
            ('http://www.python.org',
             ('http', 'www.python.org', '', '', '', ''),
             ('http', 'www.python.org', '', '', '')),
            ('http://www.python.org#abc',
             ('http', 'www.python.org', '', '', '', 'abc'),
             ('http', 'www.python.org', '', '', 'abc')),
            ('http://www.python.org/#abc',
             ('http', 'www.python.org', '/', '', '', 'abc'),
             ('http', 'www.python.org', '/', '', 'abc')),
            (RFC1808_BASE,
             ('http', 'a', '/b/c/d', 'p', 'q', 'f'),
             ('http', 'a', '/b/c/d;p', 'q', 'f')),
            ('file:///tmp/junk.txt',
             ('file', '', '/tmp/junk.txt', '', '', ''),
             ('file', '', '/tmp/junk.txt', '', '')),
            ('imap://mail.python.org/mbox1',
             ('imap', 'mail.python.org', '/mbox1', '', '', ''),
             ('imap', 'mail.python.org', '/mbox1', '', '')),
            ('mms://wms.sys.hinet.net/cts/Drama/09006251100.asf',
             ('mms', 'wms.sys.hinet.net', '/cts/Drama/09006251100.asf', '', '', ''),
             ('mms', 'wms.sys.hinet.net', '/cts/Drama/09006251100.asf', '', '')),
            ]:
            result = urlparse.urlparse(url)
            self.assertEqual(result, parsed)
            # put it back together and it should be the same
            result2 = urlparse.urlunparse(result)
            self.assertEqual(result2, url)

            # check the roundtrip using urlsplit() as well
            result = urlparse.urlsplit(url)
            self.assertEqual(result, split)
            result2 = urlparse.urlunsplit(result)
            self.assertEqual(result2, url)

    def checkJoin(self, base, relurl, expected):
        self.assertEqual(urlparse.urljoin(base, relurl), expected,
                         (base, relurl, expected))

    def test_unparse_parse(self):
        for u in ['Python', './Python']:
            self.assertEqual(urlparse.urlunsplit(urlparse.urlsplit(u)), u)
            self.assertEqual(urlparse.urlunparse(urlparse.urlparse(u)), u)

    def test_RFC1808(self):
        # "normal" cases from RFC 1808:
        self.checkJoin(RFC1808_BASE, 'g:h', 'g:h')
        self.checkJoin(RFC1808_BASE, 'g', 'http://a/b/c/g')
        self.checkJoin(RFC1808_BASE, './g', 'http://a/b/c/g')
        self.checkJoin(RFC1808_BASE, 'g/', 'http://a/b/c/g/')
        self.checkJoin(RFC1808_BASE, '/g', 'http://a/g')
        self.checkJoin(RFC1808_BASE, '//g', 'http://g')
        self.checkJoin(RFC1808_BASE, '?y', 'http://a/b/c/d;p?y')
        self.checkJoin(RFC1808_BASE, 'g?y', 'http://a/b/c/g?y')
        self.checkJoin(RFC1808_BASE, 'g?y/./x', 'http://a/b/c/g?y/./x')
        self.checkJoin(RFC1808_BASE, '#s', 'http://a/b/c/d;p?q#s')
        self.checkJoin(RFC1808_BASE, 'g#s', 'http://a/b/c/g#s')
        self.checkJoin(RFC1808_BASE, 'g#s/./x', 'http://a/b/c/g#s/./x')
        self.checkJoin(RFC1808_BASE, 'g?y#s', 'http://a/b/c/g?y#s')
        self.checkJoin(RFC1808_BASE, ';x', 'http://a/b/c/d;x')
        self.checkJoin(RFC1808_BASE, 'g;x', 'http://a/b/c/g;x')
        self.checkJoin(RFC1808_BASE, 'g;x?y#s', 'http://a/b/c/g;x?y#s')
        self.checkJoin(RFC1808_BASE, '.', 'http://a/b/c/')
        self.checkJoin(RFC1808_BASE, './', 'http://a/b/c/')
        self.checkJoin(RFC1808_BASE, '..', 'http://a/b/')
        self.checkJoin(RFC1808_BASE, '../', 'http://a/b/')
        self.checkJoin(RFC1808_BASE, '../g', 'http://a/b/g')
        self.checkJoin(RFC1808_BASE, '../..', 'http://a/')
        self.checkJoin(RFC1808_BASE, '../../', 'http://a/')
        self.checkJoin(RFC1808_BASE, '../../g', 'http://a/g')

        # "abnormal" cases from RFC 1808:
        self.checkJoin(RFC1808_BASE, '', 'http://a/b/c/d;p?q#f')
        self.checkJoin(RFC1808_BASE, '../../../g', 'http://a/../g')
        self.checkJoin(RFC1808_BASE, '../../../../g', 'http://a/../../g')
        self.checkJoin(RFC1808_BASE, '/./g', 'http://a/./g')
        self.checkJoin(RFC1808_BASE, '/../g', 'http://a/../g')
        self.checkJoin(RFC1808_BASE, 'g.', 'http://a/b/c/g.')
        self.checkJoin(RFC1808_BASE, '.g', 'http://a/b/c/.g')
        self.checkJoin(RFC1808_BASE, 'g..', 'http://a/b/c/g..')
        self.checkJoin(RFC1808_BASE, '..g', 'http://a/b/c/..g')
        self.checkJoin(RFC1808_BASE, './../g', 'http://a/b/g')
        self.checkJoin(RFC1808_BASE, './g/.', 'http://a/b/c/g/')
        self.checkJoin(RFC1808_BASE, 'g/./h', 'http://a/b/c/g/h')
        self.checkJoin(RFC1808_BASE, 'g/../h', 'http://a/b/c/h')

        # RFC 1808 and RFC 1630 disagree on these (according to RFC 1808),
        # so we'll not actually run these tests (which expect 1808 behavior).
        #self.checkJoin(RFC1808_BASE, 'http:g', 'http:g')
        #self.checkJoin(RFC1808_BASE, 'http:', 'http:')

    def test_RFC2396(self):
        # cases from RFC 2396

        ### urlparse.py as of v 1.32 fails on these two
        #self.checkJoin(RFC2396_BASE, '?y', 'http://a/b/c/?y')
        #self.checkJoin(RFC2396_BASE, ';x', 'http://a/b/c/;x')

        self.checkJoin(RFC2396_BASE, 'g:h', 'g:h')
        self.checkJoin(RFC2396_BASE, 'g', 'http://a/b/c/g')
        self.checkJoin(RFC2396_BASE, './g', 'http://a/b/c/g')
        self.checkJoin(RFC2396_BASE, 'g/', 'http://a/b/c/g/')
        self.checkJoin(RFC2396_BASE, '/g', 'http://a/g')
        self.checkJoin(RFC2396_BASE, '//g', 'http://g')
        self.checkJoin(RFC2396_BASE, 'g?y', 'http://a/b/c/g?y')
        self.checkJoin(RFC2396_BASE, '#s', 'http://a/b/c/d;p?q#s')
        self.checkJoin(RFC2396_BASE, 'g#s', 'http://a/b/c/g#s')
        self.checkJoin(RFC2396_BASE, 'g?y#s', 'http://a/b/c/g?y#s')
        self.checkJoin(RFC2396_BASE, 'g;x', 'http://a/b/c/g;x')
        self.checkJoin(RFC2396_BASE, 'g;x?y#s', 'http://a/b/c/g;x?y#s')
        self.checkJoin(RFC2396_BASE, '.', 'http://a/b/c/')
        self.checkJoin(RFC2396_BASE, './', 'http://a/b/c/')
        self.checkJoin(RFC2396_BASE, '..', 'http://a/b/')
        self.checkJoin(RFC2396_BASE, '../', 'http://a/b/')
        self.checkJoin(RFC2396_BASE, '../g', 'http://a/b/g')
        self.checkJoin(RFC2396_BASE, '../..', 'http://a/')
        self.checkJoin(RFC2396_BASE, '../../', 'http://a/')
        self.checkJoin(RFC2396_BASE, '../../g', 'http://a/g')
        self.checkJoin(RFC2396_BASE, '', RFC2396_BASE)
        self.checkJoin(RFC2396_BASE, '../../../g', 'http://a/../g')
        self.checkJoin(RFC2396_BASE, '../../../../g', 'http://a/../../g')
        self.checkJoin(RFC2396_BASE, '/./g', 'http://a/./g')
        self.checkJoin(RFC2396_BASE, '/../g', 'http://a/../g')
        self.checkJoin(RFC2396_BASE, 'g.', 'http://a/b/c/g.')
        self.checkJoin(RFC2396_BASE, '.g', 'http://a/b/c/.g')
        self.checkJoin(RFC2396_BASE, 'g..', 'http://a/b/c/g..')
        self.checkJoin(RFC2396_BASE, '..g', 'http://a/b/c/..g')
        self.checkJoin(RFC2396_BASE, './../g', 'http://a/b/g')
        self.checkJoin(RFC2396_BASE, './g/.', 'http://a/b/c/g/')
        self.checkJoin(RFC2396_BASE, 'g/./h', 'http://a/b/c/g/h')
        self.checkJoin(RFC2396_BASE, 'g/../h', 'http://a/b/c/h')
        self.checkJoin(RFC2396_BASE, 'g;x=1/./y', 'http://a/b/c/g;x=1/y')
        self.checkJoin(RFC2396_BASE, 'g;x=1/../y', 'http://a/b/c/y')
        self.checkJoin(RFC2396_BASE, 'g?y/./x', 'http://a/b/c/g?y/./x')
        self.checkJoin(RFC2396_BASE, 'g?y/../x', 'http://a/b/c/g?y/../x')
        self.checkJoin(RFC2396_BASE, 'g#s/./x', 'http://a/b/c/g#s/./x')
        self.checkJoin(RFC2396_BASE, 'g#s/../x', 'http://a/b/c/g#s/../x')

    def test_urldefrag(self):
        for url, defrag, frag in [
            ('http://python.org#frag', 'http://python.org', 'frag'),
            ('http://python.org', 'http://python.org', ''),
            ('http://python.org/#frag', 'http://python.org/', 'frag'),
            ('http://python.org/', 'http://python.org/', ''),
            ('http://python.org/?q#frag', 'http://python.org/?q', 'frag'),
            ('http://python.org/?q', 'http://python.org/?q', ''),
            ('http://python.org/p#frag', 'http://python.org/p', 'frag'),
            ('http://python.org/p?q', 'http://python.org/p?q', ''),
            (RFC1808_BASE, 'http://a/b/c/d;p?q', 'f'),
            (RFC2396_BASE, 'http://a/b/c/d;p?q', ''),
            ]:
            self.assertEqual(urlparse.urldefrag(url), (defrag, frag))

def test_main():
    test_support.run_unittest(UrlParseTestCase)

if __name__ == "__main__":
    test_main()
