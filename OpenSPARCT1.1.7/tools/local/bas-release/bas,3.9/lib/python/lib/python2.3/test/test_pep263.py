#! -*- coding: koi8-r -*-
assert u"�����".encode("utf-8") == '\xd0\x9f\xd0\xb8\xd1\x82\xd0\xbe\xd0\xbd'
assert u"\�".encode("utf-8") == '\\\xd0\x9f'
