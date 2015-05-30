# This file was created automatically by SWIG 1.3.28.
# Don't modify this file, modify the SWIG interface instead.
# This file is compatible with both classic and new-style classes.

import _riesling_n1
import new
new_instancemethod = new.instancemethod
def _swig_setattr_nondynamic(self,class_type,name,value,static=1):
    if (name == "thisown"): return self.this.own(value)
    if (name == "this"):
        if type(value).__name__ == 'PySwigObject':
            self.__dict__[name] = value
            return
    method = class_type.__swig_setmethods__.get(name,None)
    if method: return method(self,value)
    if (not static) or hasattr(self,name):
        self.__dict__[name] = value
    else:
        raise AttributeError("You cannot add attributes to %s" % self)

def _swig_setattr(self,class_type,name,value):
    return _swig_setattr_nondynamic(self,class_type,name,value,0)

def _swig_getattr(self,class_type,name):
    if (name == "thisown"): return self.this.own()
    method = class_type.__swig_getmethods__.get(name,None)
    if method: return method(self)
    raise AttributeError,name

import types
try:
    _object = types.ObjectType
    _newclass = 1
except AttributeError:
    class _object : pass
    _newclass = 0
del types


class Object(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Object, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Object, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Object instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Object_toString(*args)
    def typeName(*args): return _riesling_n1.Object_typeName(*args)
_riesling_n1.Object_swigregister(Object)

class Exception(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, Exception, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, Exception, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Exception instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
_riesling_n1.Exception_swigregister(Exception)

class SparcArchViolation(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, SparcArchViolation, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, SparcArchViolation, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::SparcArchViolation instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_SparcArchViolation(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.SparcArchViolation_toString(*args)
_riesling_n1.SparcArchViolation_swigregister(SparcArchViolation)

class LogicError(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, LogicError, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, LogicError, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::LogicError instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
_riesling_n1.LogicError_swigregister(LogicError)

class InvalidArgument(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, InvalidArgument, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, InvalidArgument, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::InvalidArgument instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_InvalidArgument(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.InvalidArgument_toString(*args)
_riesling_n1.InvalidArgument_swigregister(InvalidArgument)

class LengthError(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, LengthError, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, LengthError, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::LengthError instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_LengthError(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.LengthError_toString(*args)
_riesling_n1.LengthError_swigregister(LengthError)

class OutOfRange(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, OutOfRange, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, OutOfRange, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::OutOfRange instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_OutOfRange(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.OutOfRange_toString(*args)
_riesling_n1.OutOfRange_swigregister(OutOfRange)

class DomainError(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, DomainError, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, DomainError, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::DomainError instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_DomainError(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.DomainError_toString(*args)
_riesling_n1.DomainError_swigregister(DomainError)

class FieldObject(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, FieldObject, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, FieldObject, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::FieldObject instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def getNative(*args): return _riesling_n1.FieldObject_getNative(*args)
    def setNative(*args): return _riesling_n1.FieldObject_setNative(*args)
_riesling_n1.FieldObject_swigregister(FieldObject)

class RegisterFile(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, RegisterFile, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, RegisterFile, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::RegisterFile instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_RegisterFile(*args)
        try: self.this.append(this)
        except: self.this = this
    __swig_destroy__ = _riesling_n1.delete_RegisterFile
    __del__ = lambda self : None;
    def toString(*args): return _riesling_n1.RegisterFile_toString(*args)
    def getCWP(*args): return _riesling_n1.RegisterFile_getCWP(*args)
    def getCANSAVE(*args): return _riesling_n1.RegisterFile_getCANSAVE(*args)
    def getCANRESTORE(*args): return _riesling_n1.RegisterFile_getCANRESTORE(*args)
    def getOTHERWIN(*args): return _riesling_n1.RegisterFile_getOTHERWIN(*args)
    def getNWINDOWS(*args): return _riesling_n1.RegisterFile_getNWINDOWS(*args)
    def getCLEANWIN(*args): return _riesling_n1.RegisterFile_getCLEANWIN(*args)
    def setCWP(*args): return _riesling_n1.RegisterFile_setCWP(*args)
    def setCANSAVE(*args): return _riesling_n1.RegisterFile_setCANSAVE(*args)
    def setCANRESTORE(*args): return _riesling_n1.RegisterFile_setCANRESTORE(*args)
    def setOTHERWIN(*args): return _riesling_n1.RegisterFile_setOTHERWIN(*args)
    def setCLEANWIN(*args): return _riesling_n1.RegisterFile_setCLEANWIN(*args)
    def selectGlobalSet(*args): return _riesling_n1.RegisterFile_selectGlobalSet(*args)
    def get(*args): return _riesling_n1.RegisterFile_get(*args)
    def set(*args): return _riesling_n1.RegisterFile_set(*args)
_riesling_n1.RegisterFile_swigregister(RegisterFile)

class FloatRegisterFile(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, FloatRegisterFile, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, FloatRegisterFile, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::FloatRegisterFile instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_FloatRegisterFile(*args)
        try: self.this.append(this)
        except: self.this = this
    __swig_destroy__ = _riesling_n1.delete_FloatRegisterFile
    __del__ = lambda self : None;
    def toString(*args): return _riesling_n1.FloatRegisterFile_toString(*args)
    def getSpfp(*args): return _riesling_n1.FloatRegisterFile_getSpfp(*args)
    def getFloat(*args): return _riesling_n1.FloatRegisterFile_getFloat(*args)
    def getDpfp(*args): return _riesling_n1.FloatRegisterFile_getDpfp(*args)
    def getDouble(*args): return _riesling_n1.FloatRegisterFile_getDouble(*args)
    def getQuadHigh(*args): return _riesling_n1.FloatRegisterFile_getQuadHigh(*args)
    def getQuadLow(*args): return _riesling_n1.FloatRegisterFile_getQuadLow(*args)
    def setSpfp(*args): return _riesling_n1.FloatRegisterFile_setSpfp(*args)
    def setFloat(*args): return _riesling_n1.FloatRegisterFile_setFloat(*args)
    def setDpfp(*args): return _riesling_n1.FloatRegisterFile_setDpfp(*args)
    def setDouble(*args): return _riesling_n1.FloatRegisterFile_setDouble(*args)
    def setQuadHigh(*args): return _riesling_n1.FloatRegisterFile_setQuadHigh(*args)
    def setQuadLow(*args): return _riesling_n1.FloatRegisterFile_setQuadLow(*args)
_riesling_n1.FloatRegisterFile_swigregister(FloatRegisterFile)

class V9_TrapType(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TrapType, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TrapType, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_TrapType instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_V9_TrapType(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.V9_TrapType_toString(*args)
    def getTrapType(*args): return _riesling_n1.V9_TrapType_getTrapType(*args)
    def setTrapType(*args): return _riesling_n1.V9_TrapType_setTrapType(*args)
_riesling_n1.V9_TrapType_swigregister(V9_TrapType)

class InstructionWord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, InstructionWord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, InstructionWord, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::InstructionWord instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.InstructionWord_toString(*args)
    def getNative(*args): return _riesling_n1.InstructionWord_getNative(*args)
    def getPc(*args): return _riesling_n1.InstructionWord_getPc(*args)
    def getPpc(*args): return _riesling_n1.InstructionWord_getPpc(*args)
_riesling_n1.InstructionWord_swigregister(InstructionWord)

class Hv_InstructionWord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_InstructionWord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_InstructionWord, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_InstructionWord instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_InstructionWord_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_InstructionWord_getNative(*args)
    def getPc(*args): return _riesling_n1.Hv_InstructionWord_getPc(*args)
    def getPpc(*args): return _riesling_n1.Hv_InstructionWord_getPpc(*args)
_riesling_n1.Hv_InstructionWord_swigregister(Hv_InstructionWord)

class V9_TickReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TickReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TickReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_TickReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_TickReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_TickReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_TickReg_setNative(*args)
_riesling_n1.V9_TickReg_swigregister(V9_TickReg)

class Sf_SoftIntReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_SoftIntReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_SoftIntReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Sf_SoftIntReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Sf_SoftIntReg_toString(*args)
    def getNative(*args): return _riesling_n1.Sf_SoftIntReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Sf_SoftIntReg_setNative(*args)
_riesling_n1.Sf_SoftIntReg_swigregister(Sf_SoftIntReg)

class V9_TickCompareReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TickCompareReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TickCompareReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_TickCompareReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_TickCompareReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_TickCompareReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_TickCompareReg_setNative(*args)
_riesling_n1.V9_TickCompareReg_swigregister(V9_TickCompareReg)

class V9_CcrReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_CcrReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_CcrReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_CcrReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_CcrReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_CcrReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_CcrReg_setNative(*args)
_riesling_n1.V9_CcrReg_swigregister(V9_CcrReg)

class V9_YReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_YReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_YReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_YReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_YReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_YReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_YReg_setNative(*args)
_riesling_n1.V9_YReg_swigregister(V9_YReg)

class V9_FprsReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_FprsReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_FprsReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_FprsReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_FprsReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_FprsReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_FprsReg_setNative(*args)
_riesling_n1.V9_FprsReg_swigregister(V9_FprsReg)

class V9_FsrReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_FsrReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_FsrReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_FsrReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_FsrReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_FsrReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_FsrReg_setNative(*args)
_riesling_n1.V9_FsrReg_swigregister(V9_FsrReg)

class V9_TbaReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TbaReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TbaReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_TbaReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_TbaReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_TbaReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_TbaReg_setNative(*args)
_riesling_n1.V9_TbaReg_swigregister(V9_TbaReg)

class V9_PilReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_PilReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_PilReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_PilReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_PilReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_PilReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_PilReg_setNative(*args)
_riesling_n1.V9_PilReg_swigregister(V9_PilReg)

class V9_AsiReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_AsiReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_AsiReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_AsiReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_AsiReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_AsiReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_AsiReg_setNative(*args)
_riesling_n1.V9_AsiReg_swigregister(V9_AsiReg)

class V9_Tpc(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_Tpc, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_Tpc, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_Tpc instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_Tpc_toString(*args)
    def getTpc(*args): return _riesling_n1.V9_Tpc_getTpc(*args)
    def setTpc(*args): return _riesling_n1.V9_Tpc_setTpc(*args)
    def getMaxTl(*args): return _riesling_n1.V9_Tpc_getMaxTl(*args)
_riesling_n1.V9_Tpc_swigregister(V9_Tpc)

class V9_Tnpc(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_Tnpc, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_Tnpc, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_Tnpc instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_Tnpc_toString(*args)
    def getTnpc(*args): return _riesling_n1.V9_Tnpc_getTnpc(*args)
    def setTnpc(*args): return _riesling_n1.V9_Tnpc_setTnpc(*args)
_riesling_n1.V9_Tnpc_swigregister(V9_Tnpc)

class V9_WstateReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_WstateReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_WstateReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_WstateReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_WstateReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_WstateReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_WstateReg_setNative(*args)
_riesling_n1.V9_WstateReg_swigregister(V9_WstateReg)

class V9_TrapLevelReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TrapLevelReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TrapLevelReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_TrapLevelReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_TrapLevelReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_TrapLevelReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_TrapLevelReg_setNative(*args)
_riesling_n1.V9_TrapLevelReg_swigregister(V9_TrapLevelReg)

class V9_VerReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_VerReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_VerReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::V9_VerReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.V9_VerReg_toString(*args)
    def getNative(*args): return _riesling_n1.V9_VerReg_getNative(*args)
    def setNative(*args): return _riesling_n1.V9_VerReg_setNative(*args)
_riesling_n1.V9_VerReg_swigregister(V9_VerReg)

class CMP_CoreAvailableReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreAvailableReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreAvailableReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_CoreAvailableReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_CoreAvailableReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_CoreAvailableReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_CoreAvailableReg_setNative(*args)
    def setAVAILABLE(*args): return _riesling_n1.CMP_CoreAvailableReg_setAVAILABLE(*args)
_riesling_n1.CMP_CoreAvailableReg_swigregister(CMP_CoreAvailableReg)

class CMP_CoreEnabledReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreEnabledReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreEnabledReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_CoreEnabledReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_CoreEnabledReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_CoreEnabledReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_CoreEnabledReg_setNative(*args)
    def setENABLED(*args): return _riesling_n1.CMP_CoreEnabledReg_setENABLED(*args)
_riesling_n1.CMP_CoreEnabledReg_swigregister(CMP_CoreEnabledReg)

class CMP_CoreEnableReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreEnableReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreEnableReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_CoreEnableReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_CoreEnableReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_CoreEnableReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_CoreEnableReg_setNative(*args)
    def setENABLE(*args): return _riesling_n1.CMP_CoreEnableReg_setENABLE(*args)
_riesling_n1.CMP_CoreEnableReg_swigregister(CMP_CoreEnableReg)

class CMP_CoreRunningReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreRunningReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreRunningReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_CoreRunningReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_CoreRunningReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_CoreRunningReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_CoreRunningReg_setNative(*args)
    def setRUNNING(*args): return _riesling_n1.CMP_CoreRunningReg_setRUNNING(*args)
_riesling_n1.CMP_CoreRunningReg_swigregister(CMP_CoreRunningReg)

class CMP_CoreRunningStatusReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreRunningStatusReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreRunningStatusReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_CoreRunningStatusReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_CoreRunningStatusReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_CoreRunningStatusReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_CoreRunningStatusReg_setNative(*args)
    def setRUNNING_STATUS(*args): return _riesling_n1.CMP_CoreRunningStatusReg_setRUNNING_STATUS(*args)
_riesling_n1.CMP_CoreRunningStatusReg_swigregister(CMP_CoreRunningStatusReg)

class CMP_ErrorSteeringReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_ErrorSteeringReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_ErrorSteeringReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_ErrorSteeringReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_ErrorSteeringReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_ErrorSteeringReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_ErrorSteeringReg_setNative(*args)
_riesling_n1.CMP_ErrorSteeringReg_swigregister(CMP_ErrorSteeringReg)

class CMP_XirSteeringReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_XirSteeringReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_XirSteeringReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_XirSteeringReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_XirSteeringReg_toString(*args)
    def getNative(*args): return _riesling_n1.CMP_XirSteeringReg_getNative(*args)
    def setNative(*args): return _riesling_n1.CMP_XirSteeringReg_setNative(*args)
_riesling_n1.CMP_XirSteeringReg_swigregister(CMP_XirSteeringReg)

class CMP_CpuLevelCmpRegs(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CpuLevelCmpRegs, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CpuLevelCmpRegs, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::CMP_CpuLevelCmpRegs instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_toString(*args)
    def getCoreAvailableRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getCoreAvailableRegPtr(*args)
    def getCoreEnabledRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getCoreEnabledRegPtr(*args)
    def getCoreEnableRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getCoreEnableRegPtr(*args)
    def getCoreRunningRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getCoreRunningRegPtr(*args)
    def getCoreRunningStatusRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getCoreRunningStatusRegPtr(*args)
    def getErrorSteeringRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getErrorSteeringRegPtr(*args)
    def getXirSteeringRegPtr(*args): return _riesling_n1.CMP_CpuLevelCmpRegs_getXirSteeringRegPtr(*args)
_riesling_n1.CMP_CpuLevelCmpRegs_swigregister(CMP_CpuLevelCmpRegs)

class MemoryInterface(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, MemoryInterface, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, MemoryInterface, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::MemoryInterface instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def read(*args): return _riesling_n1.MemoryInterface_read(*args)
    def write(*args): return _riesling_n1.MemoryInterface_write(*args)
_riesling_n1.MemoryInterface_swigregister(MemoryInterface)

class SparseMemory(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, SparseMemory, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, SparseMemory, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::SparseMemory instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_SparseMemory(*args)
        try: self.this.append(this)
        except: self.this = this
    def read32(*args): return _riesling_n1.SparseMemory_read32(*args)
    def read64(*args): return _riesling_n1.SparseMemory_read64(*args)
    def write32(*args): return _riesling_n1.SparseMemory_write32(*args)
    def write64(*args): return _riesling_n1.SparseMemory_write64(*args)
    def pageCount(*args): return _riesling_n1.SparseMemory_pageCount(*args)
_riesling_n1.SparseMemory_swigregister(SparseMemory)

class BreakpointTable(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, BreakpointTable, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, BreakpointTable, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::BreakpointTable instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.BreakpointTable_toString(*args)
    def add(*args): return _riesling_n1.BreakpointTable_add(*args)
    def remove(*args): return _riesling_n1.BreakpointTable_remove(*args)
    def enable(*args): return _riesling_n1.BreakpointTable_enable(*args)
    def disable(*args): return _riesling_n1.BreakpointTable_disable(*args)
    def list(*args): return _riesling_n1.BreakpointTable_list(*args)
    def query(*args): return _riesling_n1.BreakpointTable_query(*args)
    def querySid(*args): return _riesling_n1.BreakpointTable_querySid(*args)
    def queryLast(*args): return _riesling_n1.BreakpointTable_queryLast(*args)
    def queryLastSid(*args): return _riesling_n1.BreakpointTable_queryLastSid(*args)
    def isBadTrap(*args): return _riesling_n1.BreakpointTable_isBadTrap(*args)
_riesling_n1.BreakpointTable_swigregister(BreakpointTable)


decmode = _riesling_n1.decmode

hexmode = _riesling_n1.hexmode

conv_w2f = _riesling_n1.conv_w2f

conv_f2w = _riesling_n1.conv_f2w

conv_x2d = _riesling_n1.conv_x2d

conv_d2x = _riesling_n1.conv_d2x

conv_x2x = _riesling_n1.conv_x2x

conv_w2w = _riesling_n1.conv_w2w

conv_h2h = _riesling_n1.conv_h2h

n1_system_base = _riesling_n1.n1_system_base
class Ni_Tlb(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Tlb, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Tlb, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Tlb instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_Tlb_toString(*args)
    def insert(*args): return _riesling_n1.Ni_Tlb_insert(*args)
    def at(*args): return _riesling_n1.Ni_Tlb_at(*args)
    def getNLines(*args): return _riesling_n1.Ni_Tlb_getNLines(*args)
    def next_valid_index(*args): return _riesling_n1.Ni_Tlb_next_valid_index(*args)
_riesling_n1.Ni_Tlb_swigregister(Ni_Tlb)

class Ni_Tte(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Tte, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Tte, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Tte instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_Ni_Tte(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.Ni_Tte_toString(*args)
    def data4u(*args): return _riesling_n1.Ni_Tte_data4u(*args)
    def context(*args): return _riesling_n1.Ni_Tte_context(*args)
    def pid(*args): return _riesling_n1.Ni_Tte_pid(*args)
    def vaddr(*args): return _riesling_n1.Ni_Tte_vaddr(*args)
    def r(*args): return _riesling_n1.Ni_Tte_r(*args)
    def translate(*args): return _riesling_n1.Ni_Tte_translate(*args)
    def tagMatch(*args): return _riesling_n1.Ni_Tte_tagMatch(*args)
_riesling_n1.Ni_Tte_swigregister(Ni_Tte)

class Ni_TteDataSun4u(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_TteDataSun4u, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_TteDataSun4u, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_TteDataSun4u instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_Ni_TteDataSun4u(*args)
        try: self.this.append(this)
        except: self.this = this
    def getNative(*args): return _riesling_n1.Ni_TteDataSun4u_getNative(*args)
    def setNative(*args): return _riesling_n1.Ni_TteDataSun4u_setNative(*args)
    def getV(*args): return _riesling_n1.Ni_TteDataSun4u_getV(*args)
    def getSZL(*args): return _riesling_n1.Ni_TteDataSun4u_getSZL(*args)
    def getNFO(*args): return _riesling_n1.Ni_TteDataSun4u_getNFO(*args)
    def getIE(*args): return _riesling_n1.Ni_TteDataSun4u_getIE(*args)
    def getSZH(*args): return _riesling_n1.Ni_TteDataSun4u_getSZH(*args)
    def getDIAG7_3(*args): return _riesling_n1.Ni_TteDataSun4u_getDIAG7_3(*args)
    def getPA(*args): return _riesling_n1.Ni_TteDataSun4u_getPA(*args)
    def getL(*args): return _riesling_n1.Ni_TteDataSun4u_getL(*args)
    def getCP(*args): return _riesling_n1.Ni_TteDataSun4u_getCP(*args)
    def getCV(*args): return _riesling_n1.Ni_TteDataSun4u_getCV(*args)
    def getE(*args): return _riesling_n1.Ni_TteDataSun4u_getE(*args)
    def getP(*args): return _riesling_n1.Ni_TteDataSun4u_getP(*args)
    def getW(*args): return _riesling_n1.Ni_TteDataSun4u_getW(*args)
    def setV(*args): return _riesling_n1.Ni_TteDataSun4u_setV(*args)
    def setSZL(*args): return _riesling_n1.Ni_TteDataSun4u_setSZL(*args)
    def setNFO(*args): return _riesling_n1.Ni_TteDataSun4u_setNFO(*args)
    def setIE(*args): return _riesling_n1.Ni_TteDataSun4u_setIE(*args)
    def setSZH(*args): return _riesling_n1.Ni_TteDataSun4u_setSZH(*args)
    def setDIAG7_3(*args): return _riesling_n1.Ni_TteDataSun4u_setDIAG7_3(*args)
    def setPA(*args): return _riesling_n1.Ni_TteDataSun4u_setPA(*args)
    def setL(*args): return _riesling_n1.Ni_TteDataSun4u_setL(*args)
    def setCP(*args): return _riesling_n1.Ni_TteDataSun4u_setCP(*args)
    def setCV(*args): return _riesling_n1.Ni_TteDataSun4u_setCV(*args)
    def setE(*args): return _riesling_n1.Ni_TteDataSun4u_setE(*args)
    def setP(*args): return _riesling_n1.Ni_TteDataSun4u_setP(*args)
    def setW(*args): return _riesling_n1.Ni_TteDataSun4u_setW(*args)
_riesling_n1.Ni_TteDataSun4u_swigregister(Ni_TteDataSun4u)

class Ni_IDPartitionIdReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_IDPartitionIdReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_IDPartitionIdReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_IDPartitionIdReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_IDPartitionIdReg_toString(*args)
    def getNative(*args): return _riesling_n1.Ni_IDPartitionIdReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Ni_IDPartitionIdReg_setNative(*args)
_riesling_n1.Ni_IDPartitionIdReg_swigregister(Ni_IDPartitionIdReg)

class Sf_ContextReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_ContextReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_ContextReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Sf_ContextReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Sf_ContextReg_toString(*args)
    def getNative(*args): return _riesling_n1.Sf_ContextReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Sf_ContextReg_setNative(*args)
_riesling_n1.Sf_ContextReg_swigregister(Sf_ContextReg)

class Sf_TagTargetReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_TagTargetReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_TagTargetReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Sf_TagTargetReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Sf_TagTargetReg_toString(*args)
    def getNative(*args): return _riesling_n1.Sf_TagTargetReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Sf_TagTargetReg_setNative(*args)
_riesling_n1.Sf_TagTargetReg_swigregister(Sf_TagTargetReg)

class Sf_TagAccessReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_TagAccessReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_TagAccessReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Sf_TagAccessReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Sf_TagAccessReg_toString(*args)
    def getNative(*args): return _riesling_n1.Sf_TagAccessReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Sf_TagAccessReg_setNative(*args)
_riesling_n1.Sf_TagAccessReg_swigregister(Sf_TagAccessReg)

class Ni_Mmu(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Mmu, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Mmu, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Mmu instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_Mmu_toString(*args)
_riesling_n1.Ni_Mmu_swigregister(Ni_Mmu)

class Ni_InstructionWord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_InstructionWord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_InstructionWord, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_InstructionWord instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_InstructionWord_toString(*args)
    def getNative(*args): return _riesling_n1.Ni_InstructionWord_getNative(*args)
    def getPc(*args): return _riesling_n1.Ni_InstructionWord_getPc(*args)
    def getPpc(*args): return _riesling_n1.Ni_InstructionWord_getPpc(*args)
_riesling_n1.Ni_InstructionWord_swigregister(Ni_InstructionWord)

class Ni_TstateEntry(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_TstateEntry, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_TstateEntry, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_TstateEntry instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_Ni_TstateEntry(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.Ni_TstateEntry_toString(*args)
    def getNative(*args): return _riesling_n1.Ni_TstateEntry_getNative(*args)
    def setNative(*args): return _riesling_n1.Ni_TstateEntry_setNative(*args)
_riesling_n1.Ni_TstateEntry_swigregister(Ni_TstateEntry)

class Ni_Tstate(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Tstate, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Tstate, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Tstate instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_Tstate_toString(*args)
    def getTstateEntry(*args): return _riesling_n1.Ni_Tstate_getTstateEntry(*args)
    def setTstateEntry(*args): return _riesling_n1.Ni_Tstate_setTstateEntry(*args)
_riesling_n1.Ni_Tstate_swigregister(Ni_Tstate)

class Ni_PstateReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_PstateReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_PstateReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_PstateReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_PstateReg_toString(*args)
    def getNative(*args): return _riesling_n1.Ni_PstateReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Ni_PstateReg_setNative(*args)
_riesling_n1.Ni_PstateReg_swigregister(Ni_PstateReg)

class Hv_HtstateEntry(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HtstateEntry, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HtstateEntry, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_HtstateEntry instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_Hv_HtstateEntry(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.Hv_HtstateEntry_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_HtstateEntry_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_HtstateEntry_setNative(*args)
_riesling_n1.Hv_HtstateEntry_swigregister(Hv_HtstateEntry)

class Hv_Htstate(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_Htstate, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_Htstate, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_Htstate instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_Htstate_toString(*args)
    def getHtstateEntry(*args): return _riesling_n1.Hv_Htstate_getHtstateEntry(*args)
    def setHtstateEntry(*args): return _riesling_n1.Hv_Htstate_setHtstateEntry(*args)
    def getMaxTl(*args): return _riesling_n1.Hv_Htstate_getMaxTl(*args)
_riesling_n1.Hv_Htstate_swigregister(Hv_Htstate)

class Vis2_GsrReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Vis2_GsrReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Vis2_GsrReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Vis2_GsrReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Vis2_GsrReg_toString(*args)
    def getNative(*args): return _riesling_n1.Vis2_GsrReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Vis2_GsrReg_setNative(*args)
_riesling_n1.Vis2_GsrReg_swigregister(Vis2_GsrReg)

class Hv_HpstateReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HpstateReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HpstateReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_HpstateReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_HpstateReg_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_HpstateReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_HpstateReg_setNative(*args)
_riesling_n1.Hv_HpstateReg_swigregister(Hv_HpstateReg)

class Hv_HtbaReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HtbaReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HtbaReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_HtbaReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_HtbaReg_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_HtbaReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_HtbaReg_setNative(*args)
_riesling_n1.Hv_HtbaReg_swigregister(Hv_HtbaReg)

class Ni_HverReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_HverReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_HverReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_HverReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_HverReg_toString(*args)
    def getNative(*args): return _riesling_n1.Ni_HverReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Ni_HverReg_setNative(*args)
_riesling_n1.Ni_HverReg_swigregister(Ni_HverReg)

class Hv_HintpReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HintpReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HintpReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_HintpReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_HintpReg_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_HintpReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_HintpReg_setNative(*args)
_riesling_n1.Hv_HintpReg_swigregister(Hv_HintpReg)

class Hv_HstickCompareReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HstickCompareReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HstickCompareReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_HstickCompareReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_HstickCompareReg_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_HstickCompareReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_HstickCompareReg_setNative(*args)
_riesling_n1.Hv_HstickCompareReg_swigregister(Hv_HstickCompareReg)

class Hv_GlobalLevelReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_GlobalLevelReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_GlobalLevelReg, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_GlobalLevelReg instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_GlobalLevelReg_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_GlobalLevelReg_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_GlobalLevelReg_setNative(*args)
_riesling_n1.Hv_GlobalLevelReg_swigregister(Hv_GlobalLevelReg)

class Hv_ScratchPad(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_ScratchPad, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_ScratchPad, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Hv_ScratchPad instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Hv_ScratchPad_toString(*args)
    def getNative(*args): return _riesling_n1.Hv_ScratchPad_getNative(*args)
    def setNative(*args): return _riesling_n1.Hv_ScratchPad_setNative(*args)
_riesling_n1.Hv_ScratchPad_swigregister(Hv_ScratchPad)

class Ni_ArchState(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_ArchState, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_ArchState, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_ArchState instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_ArchState_toString(*args)
    def getPc(*args): return _riesling_n1.Ni_ArchState_getPc(*args)
    def setPc(*args): return _riesling_n1.Ni_ArchState_setPc(*args)
    def getNpc(*args): return _riesling_n1.Ni_ArchState_getNpc(*args)
    def setNpc(*args): return _riesling_n1.Ni_ArchState_setNpc(*args)
    def getRegisterFilePtr(*args): return _riesling_n1.Ni_ArchState_getRegisterFilePtr(*args)
    def getFloatRegisterFilePtr(*args): return _riesling_n1.Ni_ArchState_getFloatRegisterFilePtr(*args)
    def getTstateRegPtr(*args): return _riesling_n1.Ni_ArchState_getTstateRegPtr(*args)
    def getPstateRegPtr(*args): return _riesling_n1.Ni_ArchState_getPstateRegPtr(*args)
    def getHtstateRegPtr(*args): return _riesling_n1.Ni_ArchState_getHtstateRegPtr(*args)
    def getGsrRegPtr(*args): return _riesling_n1.Ni_ArchState_getGsrRegPtr(*args)
    def getHpstateRegPtr(*args): return _riesling_n1.Ni_ArchState_getHpstateRegPtr(*args)
    def getHtbaRegPtr(*args): return _riesling_n1.Ni_ArchState_getHtbaRegPtr(*args)
    def getHverRegPtr(*args): return _riesling_n1.Ni_ArchState_getHverRegPtr(*args)
    def getHintpRegPtr(*args): return _riesling_n1.Ni_ArchState_getHintpRegPtr(*args)
    def getHstickCompareRegPtr(*args): return _riesling_n1.Ni_ArchState_getHstickCompareRegPtr(*args)
    def getGlobalLevelRegPtr(*args): return _riesling_n1.Ni_ArchState_getGlobalLevelRegPtr(*args)
    def getScratchPadPtr(*args): return _riesling_n1.Ni_ArchState_getScratchPadPtr(*args)
    def getStickRegPtr(*args): return _riesling_n1.Ni_ArchState_getStickRegPtr(*args)
    def getSoftIntRegPtr(*args): return _riesling_n1.Ni_ArchState_getSoftIntRegPtr(*args)
    def getTickCmprRegPtr(*args): return _riesling_n1.Ni_ArchState_getTickCmprRegPtr(*args)
    def getStickCmprRegPtr(*args): return _riesling_n1.Ni_ArchState_getStickCmprRegPtr(*args)
    def getCcrRegPtr(*args): return _riesling_n1.Ni_ArchState_getCcrRegPtr(*args)
    def getYRegPtr(*args): return _riesling_n1.Ni_ArchState_getYRegPtr(*args)
    def getFprsRegPtr(*args): return _riesling_n1.Ni_ArchState_getFprsRegPtr(*args)
    def getFsrRegPtr(*args): return _riesling_n1.Ni_ArchState_getFsrRegPtr(*args)
    def getTickRegPtr(*args): return _riesling_n1.Ni_ArchState_getTickRegPtr(*args)
    def getTbaRegPtr(*args): return _riesling_n1.Ni_ArchState_getTbaRegPtr(*args)
    def getPilRegPtr(*args): return _riesling_n1.Ni_ArchState_getPilRegPtr(*args)
    def getAsiRegPtr(*args): return _riesling_n1.Ni_ArchState_getAsiRegPtr(*args)
    def getTpcRegPtr(*args): return _riesling_n1.Ni_ArchState_getTpcRegPtr(*args)
    def getTnpcRegPtr(*args): return _riesling_n1.Ni_ArchState_getTnpcRegPtr(*args)
    def getWstateRegPtr(*args): return _riesling_n1.Ni_ArchState_getWstateRegPtr(*args)
    def getTrapLevelRegPtr(*args): return _riesling_n1.Ni_ArchState_getTrapLevelRegPtr(*args)
    def getVerRegPtr(*args): return _riesling_n1.Ni_ArchState_getVerRegPtr(*args)
    def getTrapTypeRegPtr(*args): return _riesling_n1.Ni_ArchState_getTrapTypeRegPtr(*args)
_riesling_n1.Ni_ArchState_swigregister(Ni_ArchState)

class Ni_Strand(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Strand, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Strand, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Strand instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def get_max_tl(*args): return _riesling_n1.Ni_Strand_get_max_tl(*args)
    def get_max_ptl(*args): return _riesling_n1.Ni_Strand_get_max_ptl(*args)
    def get_max_gl(*args): return _riesling_n1.Ni_Strand_get_max_gl(*args)
    def get_max_pgl(*args): return _riesling_n1.Ni_Strand_get_max_pgl(*args)
    def step(*args): return _riesling_n1.Ni_Strand_step(*args)
    def getArchStatePtr(*args): return _riesling_n1.Ni_Strand_getArchStatePtr(*args)
    def getLastInstrPtr(*args): return _riesling_n1.Ni_Strand_getLastInstrPtr(*args)
    def getMmuPtr(*args): return _riesling_n1.Ni_Strand_getMmuPtr(*args)
    def lastInstr(*args): return _riesling_n1.Ni_Strand_lastInstr(*args)
    def lastInstrToString(*args): return _riesling_n1.Ni_Strand_lastInstrToString(*args)
    def RS_getInstrPtr(*args): return _riesling_n1.Ni_Strand_RS_getInstrPtr(*args)
    def RS_translate(*args): return _riesling_n1.Ni_Strand_RS_translate(*args)
    def RS_access(*args): return _riesling_n1.Ni_Strand_RS_access(*args)
    def RS_asiRead(*args): return _riesling_n1.Ni_Strand_RS_asiRead(*args)
    def RS_asiWrite(*args): return _riesling_n1.Ni_Strand_RS_asiWrite(*args)
    def RS_dumpTlb(*args): return _riesling_n1.Ni_Strand_RS_dumpTlb(*args)
_riesling_n1.Ni_Strand_swigregister(Ni_Strand)

class Ni_Core(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Core, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Core, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Core instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_Core_toString(*args)
    def getNStrands(*args): return _riesling_n1.Ni_Core_getNStrands(*args)
    def getStrandPtr(*args): return _riesling_n1.Ni_Core_getStrandPtr(*args)
    def getdTlbPtr(*args): return _riesling_n1.Ni_Core_getdTlbPtr(*args)
    def getiTlbPtr(*args): return _riesling_n1.Ni_Core_getiTlbPtr(*args)
_riesling_n1.Ni_Core_swigregister(Ni_Core)

class Ni_Cpu(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Cpu, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Cpu, name)
    def __init__(self): raise AttributeError, "No constructor defined"
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_Cpu instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def toString(*args): return _riesling_n1.Ni_Cpu_toString(*args)
    def getNCores(*args): return _riesling_n1.Ni_Cpu_getNCores(*args)
    def getCorePtr(*args): return _riesling_n1.Ni_Cpu_getCorePtr(*args)
_riesling_n1.Ni_Cpu_swigregister(Ni_Cpu)

class Ni_System(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_System, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_System, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_System instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_Ni_System(*args)
        try: self.this.append(this)
        except: self.this = this
    def toString(*args): return _riesling_n1.Ni_System_toString(*args)
    def getNCpus(*args): return _riesling_n1.Ni_System_getNCpus(*args)
    def getCpuPtr(*args): return _riesling_n1.Ni_System_getCpuPtr(*args)
    def loadMemdatImage(*args): return _riesling_n1.Ni_System_loadMemdatImage(*args)
    def getRam(*args): return _riesling_n1.Ni_System_getRam(*args)
    def getThisPtr(*args): return _riesling_n1.Ni_System_getThisPtr(*args)
    def getBreakpointTablePtr(*args): return _riesling_n1.Ni_System_getBreakpointTablePtr(*args)
_riesling_n1.Ni_System_swigregister(Ni_System)

class Ni_SystemBase(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_SystemBase, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_SystemBase, name)
    def __repr__(self):
        try: strthis = "at 0x%x" %( self.this, ) 
        except: strthis = "" 
        return "<%s.%s; proxy of C++ Riesling::Ni_SystemBase instance %s>" % (self.__class__.__module__, self.__class__.__name__, strthis,)
    def __init__(self, *args):
        this = _riesling_n1.new_Ni_SystemBase(*args)
        try: self.this.append(this)
        except: self.this = this
    def getNCpus(*args): return _riesling_n1.Ni_SystemBase_getNCpus(*args)
    def getCpuPtr(*args): return _riesling_n1.Ni_SystemBase_getCpuPtr(*args)
    def getBreakpointTablePtr(*args): return _riesling_n1.Ni_SystemBase_getBreakpointTablePtr(*args)
_riesling_n1.Ni_SystemBase_swigregister(Ni_SystemBase)



