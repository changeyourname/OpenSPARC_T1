import unittest
from test import test_support
import zlib
import random

# print test_support.TESTFN

def getbuf():
    # This was in the original.  Avoid non-repeatable sources.
    # Left here (unused) in case something wants to be done with it.
    import imp
    try:
        t = imp.find_module('test_zlib')
        file = t[0]
    except ImportError:
        file = open(__file__)
    buf = file.read() * 8
    file.close()
    return buf



class ChecksumTestCase(unittest.TestCase):
    # checksum test cases
    def test_crc32start(self):
        self.assertEqual(zlib.crc32(""), zlib.crc32("", 0))

    def test_crc32empty(self):
        self.assertEqual(zlib.crc32("", 0), 0)
        self.assertEqual(zlib.crc32("", 1), 1)
        self.assertEqual(zlib.crc32("", 432), 432)

    def test_adler32start(self):
        self.assertEqual(zlib.adler32(""), zlib.adler32("", 1))

    def test_adler32empty(self):
        self.assertEqual(zlib.adler32("", 0), 0)
        self.assertEqual(zlib.adler32("", 1), 1)
        self.assertEqual(zlib.adler32("", 432), 432)

    def assertEqual32(self, seen, expected):
        # 32-bit values masked -- checksums on 32- vs 64- bit machines
        # This is important if bit 31 (0x08000000L) is set.
        self.assertEqual(seen & 0x0FFFFFFFFL, expected & 0x0FFFFFFFFL)

    def test_penguins(self):
        self.assertEqual32(zlib.crc32("penguin", 0), 0x0e5c1a120L)
        self.assertEqual32(zlib.crc32("penguin", 1), 0x43b6aa94)
        self.assertEqual32(zlib.adler32("penguin", 0), 0x0bcf02f6)
        self.assertEqual32(zlib.adler32("penguin", 1), 0x0bd602f7)

        self.assertEqual(zlib.crc32("penguin"), zlib.crc32("penguin", 0))
        self.assertEqual(zlib.adler32("penguin"),zlib.adler32("penguin",1))



class ExceptionTestCase(unittest.TestCase):
    # make sure we generate some expected errors
    def test_bigbits(self):
        # specifying total bits too large causes an error
        self.assertRaises(zlib.error,
                zlib.compress, 'ERROR', zlib.MAX_WBITS + 1)

    def test_badcompressobj(self):
        # verify failure on building compress object with bad params
        self.assertRaises(ValueError, zlib.compressobj, 1, 8, 0)

    def test_baddecompressobj(self):
        # verify failure on building decompress object with bad params
        self.assertRaises(ValueError, zlib.decompressobj, 0)



class CompressTestCase(unittest.TestCase):
    # Test compression in one go (whole message compression)
    def test_speech(self):
        # decompress(compress(data)) better be data
        x = zlib.compress(hamlet_scene)
        self.assertEqual(zlib.decompress(x), hamlet_scene)

    def test_speech8(self):
        # decompress(compress(data)) better be data -- more compression chances
        data = hamlet_scene * 8
        x = zlib.compress(data)
        self.assertEqual(zlib.decompress(x), data)

    def test_speech16(self):
        # decompress(compress(data)) better be data -- more compression chances
        data = hamlet_scene * 16
        x = zlib.compress(data)
        self.assertEqual(zlib.decompress(x), data)

    def test_speech128(self):
        # decompress(compress(data)) better be data -- more compression chances
        data = hamlet_scene * 8 * 16
        x = zlib.compress(data)
        self.assertEqual(zlib.decompress(x), data)




class CompressObjectTestCase(unittest.TestCase):
    # Test compression object
    def test_pairsmall(self):
        # use compress object in straightforward manner, decompress w/ object
        data = hamlet_scene
        co = zlib.compressobj(8, 8, -15)
        x1 = co.compress(data)
        x2 = co.flush()
        self.assertRaises(zlib.error, co.flush) # second flush should not work
        dco = zlib.decompressobj(-15)
        y1 = dco.decompress(x1 + x2)
        y2 = dco.flush()
        self.assertEqual(data, y1 + y2)

    def test_pair(self):
        # straightforward compress/decompress objects, more compression
        data = hamlet_scene * 8 * 16
        co = zlib.compressobj(8, 8, -15)
        x1 = co.compress(data)
        x2 = co.flush()
        self.assertRaises(zlib.error, co.flush) # second flush should not work
        dco = zlib.decompressobj(-15)
        y1 = dco.decompress(x1 + x2)
        y2 = dco.flush()
        self.assertEqual(data, y1 + y2)

    def test_compressincremental(self):
        # compress object in steps, decompress object as one-shot
        data = hamlet_scene * 8 * 16
        co = zlib.compressobj(2, 8, -12, 9, 1)
        bufs = []
        for i in range(0, len(data), 256):
            bufs.append(co.compress(data[i:i+256]))
        bufs.append(co.flush())
        combuf = ''.join(bufs)

        dco = zlib.decompressobj(-15)
        y1 = dco.decompress(''.join(bufs))
        y2 = dco.flush()
        self.assertEqual(data, y1 + y2)

    def test_decompressincremental(self):
        # compress object in steps, decompress object in steps
        data = hamlet_scene * 8 * 16
        co = zlib.compressobj(2, 8, -12, 9, 1)
        bufs = []
        for i in range(0, len(data), 256):
            bufs.append(co.compress(data[i:i+256]))
        bufs.append(co.flush())
        combuf = ''.join(bufs)

        self.assertEqual(data, zlib.decompress(combuf, -12, -5))

        dco = zlib.decompressobj(-12)
        bufs = []
        for i in range(0, len(combuf), 128):
            bufs.append(dco.decompress(combuf[i:i+128]))
            self.assertEqual('', dco.unconsumed_tail, ########
                             "(A) uct should be '': not %d long" %
                                           len(dco.unconsumed_tail))
        bufs.append(dco.flush())
        self.assertEqual('', dco.unconsumed_tail, ########
                             "(B) uct should be '': not %d long" %
                                           len(dco.unconsumed_tail))
        self.assertEqual(data, ''.join(bufs))
        # Failure means: "decompressobj with init options failed"

    def test_decompinc(self,sizes=[128],flush=True,source=None,cx=256,dcx=64):
        # compress object in steps, decompress object in steps, loop sizes
        source = source or hamlet_scene
        for reps in sizes:
            data = source * reps
            co = zlib.compressobj(2, 8, -12, 9, 1)
            bufs = []
            for i in range(0, len(data), cx):
                bufs.append(co.compress(data[i:i+cx]))
            bufs.append(co.flush())
            combuf = ''.join(bufs)

            self.assertEqual(data, zlib.decompress(combuf, -12, -5))

            dco = zlib.decompressobj(-12)
            bufs = []
            for i in range(0, len(combuf), dcx):
                bufs.append(dco.decompress(combuf[i:i+dcx]))
                self.assertEqual('', dco.unconsumed_tail, ########
                                 "(A) uct should be '': not %d long" %
                                           len(dco.unconsumed_tail))
            if flush:
                bufs.append(dco.flush())
            else:
                while True:
                    chunk = dco.decompress('')
                    if chunk:
                        bufs.append(chunk)
                    else:
                        break
            self.assertEqual('', dco.unconsumed_tail, ########
                             "(B) uct should be '': not %d long" %
                                           len(dco.unconsumed_tail))
            self.assertEqual(data, ''.join(bufs))
            # Failure means: "decompressobj with init options failed"

    def test_decompimax(self,sizes=[128],flush=True,source=None,cx=256,dcx=64):
        # compress in steps, decompress in length-restricted steps, loop sizes
        source = source or hamlet_scene
        for reps in sizes:
            # Check a decompression object with max_length specified
            data = source * reps
            co = zlib.compressobj(2, 8, -12, 9, 1)
            bufs = []
            for i in range(0, len(data), cx):
                bufs.append(co.compress(data[i:i+cx]))
            bufs.append(co.flush())
            combuf = ''.join(bufs)
            self.assertEqual(data, zlib.decompress(combuf, -12, -5),
                             'compressed data failure')

            dco = zlib.decompressobj(-12)
            bufs = []
            cb = combuf
            while cb:
                #max_length = 1 + len(cb)//10
                chunk = dco.decompress(cb, dcx)
                self.failIf(len(chunk) > dcx,
                        'chunk too big (%d>%d)' % (len(chunk), dcx))
                bufs.append(chunk)
                cb = dco.unconsumed_tail
            if flush:
                bufs.append(dco.flush())
            else:
                while True:
                    chunk = dco.decompress('', dcx)
                    self.failIf(len(chunk) > dcx,
                        'chunk too big in tail (%d>%d)' % (len(chunk), dcx))
                    if chunk:
                        bufs.append(chunk)
                    else:
                        break
            self.assertEqual(len(data), len(''.join(bufs)))
            self.assertEqual(data, ''.join(bufs), 'Wrong data retrieved')

    def test_decompressmaxlen(self):
        # Check a decompression object with max_length specified
        data = hamlet_scene * 8 * 16
        co = zlib.compressobj(2, 8, -12, 9, 1)
        bufs = []
        for i in range(0, len(data), 256):
            bufs.append(co.compress(data[i:i+256]))
        bufs.append(co.flush())
        combuf = ''.join(bufs)
        self.assertEqual(data, zlib.decompress(combuf, -12, -5),
                         'compressed data failure')

        dco = zlib.decompressobj(-12)
        bufs = []
        cb = combuf
        while cb:
            max_length = 1 + len(cb)//10
            chunk = dco.decompress(cb, max_length)
            self.failIf(len(chunk) > max_length,
                        'chunk too big (%d>%d)' % (len(chunk),max_length))
            bufs.append(chunk)
            cb = dco.unconsumed_tail
        bufs.append(dco.flush())
        self.assertEqual(len(data), len(''.join(bufs)))
        self.assertEqual(data, ''.join(bufs), 'Wrong data retrieved')

    def test_decompressmaxlenflushless(self):
        # identical to test_decompressmaxlen except flush is replaced
        # with an equivalent.  This works and other fails on (eg) 2.2.2
        data = hamlet_scene * 8 * 16
        co = zlib.compressobj(2, 8, -12, 9, 1)
        bufs = []
        for i in range(0, len(data), 256):
            bufs.append(co.compress(data[i:i+256]))
        bufs.append(co.flush())
        combuf = ''.join(bufs)
        self.assertEqual(data, zlib.decompress(combuf, -12, -5),
                         'compressed data mismatch')

        dco = zlib.decompressobj(-12)
        bufs = []
        cb = combuf
        while cb:
            max_length = 1 + len(cb)//10
            chunk = dco.decompress(cb, max_length)
            self.failIf(len(chunk) > max_length,
                        'chunk too big (%d>%d)' % (len(chunk),max_length))
            bufs.append(chunk)
            cb = dco.unconsumed_tail

        #bufs.append(dco.flush())
        while len(chunk):
            chunk = dco.decompress('', max_length)
            self.failIf(len(chunk) > max_length,
                        'chunk too big (%d>%d)' % (len(chunk),max_length))
            bufs.append(chunk)

        self.assertEqual(data, ''.join(bufs), 'Wrong data retrieved')

    def test_maxlenmisc(self):
        # Misc tests of max_length
        dco = zlib.decompressobj(-12)
        self.assertRaises(ValueError, dco.decompress, "", -1)
        self.assertEqual('', dco.unconsumed_tail)

    def test_flushes(self):
        # Test flush() with the various options, using all the
        # different levels in order to provide more variations.
        sync_opt = ['Z_NO_FLUSH', 'Z_SYNC_FLUSH', 'Z_FULL_FLUSH']
        sync_opt = [getattr(zlib, opt) for opt in sync_opt
                    if hasattr(zlib, opt)]
        data = hamlet_scene * 8

        for sync in sync_opt:
            for level in range(10):
                obj = zlib.compressobj( level )
                a = obj.compress( data[:3000] )
                b = obj.flush( sync )
                c = obj.compress( data[3000:] )
                d = obj.flush()
                self.assertEqual(zlib.decompress(''.join([a,b,c,d])),
                                 data, ("Decompress failed: flush "
                                        "mode=%i, level=%i") % (sync, level))
                del obj

    def test_odd_flush(self):
        # Test for odd flushing bugs noted in 2.0, and hopefully fixed in 2.1
        import random

        if hasattr(zlib, 'Z_SYNC_FLUSH'):
            # Testing on 17K of "random" data

            # Create compressor and decompressor objects
            co = zlib.compressobj(9)
            dco = zlib.decompressobj()

            # Try 17K of data
            # generate random data stream
            try:
                # In 2.3 and later, WichmannHill is the RNG of the bug report
                gen = random.WichmannHill()
            except AttributeError:
                try:
                    # 2.2 called it Random
                    gen = random.Random()
                except AttributeError:
                    # others might simply have a single RNG
                    gen = random
            gen.seed(1)
            data = genblock(1, 17 * 1024, generator=gen)

            # compress, sync-flush, and decompress
            first = co.compress(data)
            second = co.flush(zlib.Z_SYNC_FLUSH)
            expanded = dco.decompress(first + second)

            # if decompressed data is different from the input data, choke.
            self.assertEqual(expanded, data, "17K random source doesn't match")

    def test_manydecompinc(self):
        # Run incremental decompress test for a large range of sizes
        self.test_decompinc(sizes=[1<<n for n in range(8)],
                             flush=True, cx=32, dcx=4)

    def test_manydecompimax(self):
        # Run incremental decompress maxlen test for a large range of sizes
        # avoid the flush bug
        self.test_decompimax(sizes=[1<<n for n in range(8)],
                             flush=False, cx=32, dcx=4)

    def test_manydecompimaxflush(self):
        # Run incremental decompress maxlen test for a large range of sizes
        # avoid the flush bug
        self.test_decompimax(sizes=[1<<n for n in range(8)],
                             flush=True, cx=32, dcx=4)


def genblock(seed, length, step=1024, generator=random):
    """length-byte stream of random data from a seed (in step-byte blocks)."""
    if seed is not None:
        generator.seed(seed)
    randint = generator.randint
    if length < step or step < 2:
        step = length
    blocks = []
    for i in range(0, length, step):
        blocks.append(''.join([chr(randint(0,255))
                               for x in range(step)]))
    return ''.join(blocks)[:length]



def choose_lines(source, number, seed=None, generator=random):
    """Return a list of number lines randomly chosen from the source"""
    if seed is not None:
        generator.seed(seed)
    sources = source.split('\n')
    return [generator.choice(sources) for n in range(number)]



hamlet_scene = """
LAERTES

       O, fear me not.
       I stay too long: but here my father comes.

       Enter POLONIUS

       A double blessing is a double grace,
       Occasion smiles upon a second leave.

LORD POLONIUS

       Yet here, Laertes! aboard, aboard, for shame!
       The wind sits in the shoulder of your sail,
       And you are stay'd for. There; my blessing with thee!
       And these few precepts in thy memory
       See thou character. Give thy thoughts no tongue,
       Nor any unproportioned thought his act.
       Be thou familiar, but by no means vulgar.
       Those friends thou hast, and their adoption tried,
       Grapple them to thy soul with hoops of steel;
       But do not dull thy palm with entertainment
       Of each new-hatch'd, unfledged comrade. Beware
       Of entrance to a quarrel, but being in,
       Bear't that the opposed may beware of thee.
       Give every man thy ear, but few thy voice;
       Take each man's censure, but reserve thy judgment.
       Costly thy habit as thy purse can buy,
       But not express'd in fancy; rich, not gaudy;
       For the apparel oft proclaims the man,
       And they in France of the best rank and station
       Are of a most select and generous chief in that.
       Neither a borrower nor a lender be;
       For loan oft loses both itself and friend,
       And borrowing dulls the edge of husbandry.
       This above all: to thine ownself be true,
       And it must follow, as the night the day,
       Thou canst not then be false to any man.
       Farewell: my blessing season this in thee!

LAERTES

       Most humbly do I take my leave, my lord.

LORD POLONIUS

       The time invites you; go; your servants tend.

LAERTES

       Farewell, Ophelia; and remember well
       What I have said to you.

OPHELIA

       'Tis in my memory lock'd,
       And you yourself shall keep the key of it.

LAERTES

       Farewell.
"""


def test_main():
    test_support.run_unittest(
        ChecksumTestCase,
        ExceptionTestCase,
        CompressTestCase,
        CompressObjectTestCase
    )

if __name__ == "__main__":
    test_main()

def test(tests=''):
    if not tests: tests = 'o'
    testcases = []
    if 'k' in tests: testcases.append(ChecksumTestCase)
    if 'x' in tests: testcases.append(ExceptionTestCase)
    if 'c' in tests: testcases.append(CompressTestCase)
    if 'o' in tests: testcases.append(CompressObjectTestCase)
    test_support.run_unittest(*testcases)

if False:
    import sys
    sys.path.insert(1, '/Py23Src/python/dist/src/Lib/test')
    import test_zlib as tz
    ts, ut = tz.test_support, tz.unittest
    su = ut.TestSuite()
    su.addTest(ut.makeSuite(tz.CompressTestCase))
    ts.run_suite(su)
