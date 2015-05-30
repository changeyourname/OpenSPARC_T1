# ========== Copyright Header Begin ==========================================
# 
# OpenSPARC T1 Processor File: riesling_n1_blaze.py
# Copyright (c) 2006 Sun Microsystems, Inc.  All Rights Reserved.
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES.
# 
# The above named program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public
# License version 2 as published by the Free Software Foundation.
# 
# The above named program is distributed in the hope that it will be 
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
# 
# You should have received a copy of the GNU General Public
# License along with this work; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA.
# 
# ========== Copyright Header End ============================================
# This file was created automatically by SWIG.
# Don't modify this file, modify the SWIG interface instead.
# This file is compatible with both classic and new-style classes.

import _riesling_n1_blaze

def _swig_setattr(self,class_type,name,value):
    if (name == "this"):
        if isinstance(value, class_type):
            self.__dict__[name] = value.this
            if hasattr(value,"thisown"): self.__dict__["thisown"] = value.thisown
            del value.thisown
            return
    method = class_type.__swig_setmethods__.get(name,None)
    if method: return method(self,value)
    self.__dict__[name] = value

def _swig_getattr(self,class_type,name):
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
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Object instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Object_toString(*args)
    def typeName(*args): return _riesling_n1_blaze.Object_typeName(*args)

class ObjectPtr(Object):
    def __init__(self, this):
        _swig_setattr(self, Object, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Object, 'thisown', 0)
        _swig_setattr(self, Object,self.__class__,Object)
_riesling_n1_blaze.Object_swigregister(ObjectPtr)

class Exception(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, Exception, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, Exception, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Exception instance at %s>" % (self.this,)

class ExceptionPtr(Exception):
    def __init__(self, this):
        _swig_setattr(self, Exception, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Exception, 'thisown', 0)
        _swig_setattr(self, Exception,self.__class__,Exception)
_riesling_n1_blaze.Exception_swigregister(ExceptionPtr)

class SparcArchViolation(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, SparcArchViolation, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, SparcArchViolation, name)
    def __repr__(self):
        return "<C Riesling::SparcArchViolation instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, SparcArchViolation, 'this', _riesling_n1_blaze.new_SparcArchViolation(*args))
        _swig_setattr(self, SparcArchViolation, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.SparcArchViolation_toString(*args)

class SparcArchViolationPtr(SparcArchViolation):
    def __init__(self, this):
        _swig_setattr(self, SparcArchViolation, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, SparcArchViolation, 'thisown', 0)
        _swig_setattr(self, SparcArchViolation,self.__class__,SparcArchViolation)
_riesling_n1_blaze.SparcArchViolation_swigregister(SparcArchViolationPtr)

class LogicError(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, LogicError, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, LogicError, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::LogicError instance at %s>" % (self.this,)

class LogicErrorPtr(LogicError):
    def __init__(self, this):
        _swig_setattr(self, LogicError, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, LogicError, 'thisown', 0)
        _swig_setattr(self, LogicError,self.__class__,LogicError)
_riesling_n1_blaze.LogicError_swigregister(LogicErrorPtr)

class InvalidArgument(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, InvalidArgument, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, InvalidArgument, name)
    def __repr__(self):
        return "<C Riesling::InvalidArgument instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, InvalidArgument, 'this', _riesling_n1_blaze.new_InvalidArgument(*args))
        _swig_setattr(self, InvalidArgument, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.InvalidArgument_toString(*args)

class InvalidArgumentPtr(InvalidArgument):
    def __init__(self, this):
        _swig_setattr(self, InvalidArgument, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, InvalidArgument, 'thisown', 0)
        _swig_setattr(self, InvalidArgument,self.__class__,InvalidArgument)
_riesling_n1_blaze.InvalidArgument_swigregister(InvalidArgumentPtr)

class LengthError(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, LengthError, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, LengthError, name)
    def __repr__(self):
        return "<C Riesling::LengthError instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, LengthError, 'this', _riesling_n1_blaze.new_LengthError(*args))
        _swig_setattr(self, LengthError, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.LengthError_toString(*args)

class LengthErrorPtr(LengthError):
    def __init__(self, this):
        _swig_setattr(self, LengthError, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, LengthError, 'thisown', 0)
        _swig_setattr(self, LengthError,self.__class__,LengthError)
_riesling_n1_blaze.LengthError_swigregister(LengthErrorPtr)

class OutOfRange(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, OutOfRange, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, OutOfRange, name)
    def __repr__(self):
        return "<C Riesling::OutOfRange instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, OutOfRange, 'this', _riesling_n1_blaze.new_OutOfRange(*args))
        _swig_setattr(self, OutOfRange, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.OutOfRange_toString(*args)

class OutOfRangePtr(OutOfRange):
    def __init__(self, this):
        _swig_setattr(self, OutOfRange, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, OutOfRange, 'thisown', 0)
        _swig_setattr(self, OutOfRange,self.__class__,OutOfRange)
_riesling_n1_blaze.OutOfRange_swigregister(OutOfRangePtr)

class DomainError(Exception):
    __swig_setmethods__ = {}
    for _s in [Exception]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, DomainError, name, value)
    __swig_getmethods__ = {}
    for _s in [Exception]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, DomainError, name)
    def __repr__(self):
        return "<C Riesling::DomainError instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, DomainError, 'this', _riesling_n1_blaze.new_DomainError(*args))
        _swig_setattr(self, DomainError, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.DomainError_toString(*args)

class DomainErrorPtr(DomainError):
    def __init__(self, this):
        _swig_setattr(self, DomainError, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, DomainError, 'thisown', 0)
        _swig_setattr(self, DomainError,self.__class__,DomainError)
_riesling_n1_blaze.DomainError_swigregister(DomainErrorPtr)

class FieldObject(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, FieldObject, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, FieldObject, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::FieldObject instance at %s>" % (self.this,)
    def getNative(*args): return _riesling_n1_blaze.FieldObject_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.FieldObject_setNative(*args)

class FieldObjectPtr(FieldObject):
    def __init__(self, this):
        _swig_setattr(self, FieldObject, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, FieldObject, 'thisown', 0)
        _swig_setattr(self, FieldObject,self.__class__,FieldObject)
_riesling_n1_blaze.FieldObject_swigregister(FieldObjectPtr)

class RegisterFile(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, RegisterFile, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, RegisterFile, name)
    def __repr__(self):
        return "<C Riesling::RegisterFile instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, RegisterFile, 'this', _riesling_n1_blaze.new_RegisterFile(*args))
        _swig_setattr(self, RegisterFile, 'thisown', 1)
    def __del__(self, destroy=_riesling_n1_blaze.delete_RegisterFile):
        try:
            if self.thisown: destroy(self)
        except: pass
    def toString(*args): return _riesling_n1_blaze.RegisterFile_toString(*args)
    def getCWP(*args): return _riesling_n1_blaze.RegisterFile_getCWP(*args)
    def getCANSAVE(*args): return _riesling_n1_blaze.RegisterFile_getCANSAVE(*args)
    def getCANRESTORE(*args): return _riesling_n1_blaze.RegisterFile_getCANRESTORE(*args)
    def getOTHERWIN(*args): return _riesling_n1_blaze.RegisterFile_getOTHERWIN(*args)
    def getNWINDOWS(*args): return _riesling_n1_blaze.RegisterFile_getNWINDOWS(*args)
    def getCLEANWIN(*args): return _riesling_n1_blaze.RegisterFile_getCLEANWIN(*args)
    def setCWP(*args): return _riesling_n1_blaze.RegisterFile_setCWP(*args)
    def setCANSAVE(*args): return _riesling_n1_blaze.RegisterFile_setCANSAVE(*args)
    def setCANRESTORE(*args): return _riesling_n1_blaze.RegisterFile_setCANRESTORE(*args)
    def setOTHERWIN(*args): return _riesling_n1_blaze.RegisterFile_setOTHERWIN(*args)
    def setCLEANWIN(*args): return _riesling_n1_blaze.RegisterFile_setCLEANWIN(*args)
    def selectGlobalSet(*args): return _riesling_n1_blaze.RegisterFile_selectGlobalSet(*args)
    def get(*args): return _riesling_n1_blaze.RegisterFile_get(*args)
    def set(*args): return _riesling_n1_blaze.RegisterFile_set(*args)

class RegisterFilePtr(RegisterFile):
    def __init__(self, this):
        _swig_setattr(self, RegisterFile, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, RegisterFile, 'thisown', 0)
        _swig_setattr(self, RegisterFile,self.__class__,RegisterFile)
_riesling_n1_blaze.RegisterFile_swigregister(RegisterFilePtr)

class FloatRegisterFile(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, FloatRegisterFile, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, FloatRegisterFile, name)
    def __repr__(self):
        return "<C Riesling::FloatRegisterFile instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, FloatRegisterFile, 'this', _riesling_n1_blaze.new_FloatRegisterFile(*args))
        _swig_setattr(self, FloatRegisterFile, 'thisown', 1)
    def __del__(self, destroy=_riesling_n1_blaze.delete_FloatRegisterFile):
        try:
            if self.thisown: destroy(self)
        except: pass
    def toString(*args): return _riesling_n1_blaze.FloatRegisterFile_toString(*args)
    def getSpfp(*args): return _riesling_n1_blaze.FloatRegisterFile_getSpfp(*args)
    def getFloat(*args): return _riesling_n1_blaze.FloatRegisterFile_getFloat(*args)
    def getDpfp(*args): return _riesling_n1_blaze.FloatRegisterFile_getDpfp(*args)
    def getDouble(*args): return _riesling_n1_blaze.FloatRegisterFile_getDouble(*args)
    def getQuadHigh(*args): return _riesling_n1_blaze.FloatRegisterFile_getQuadHigh(*args)
    def getQuadLow(*args): return _riesling_n1_blaze.FloatRegisterFile_getQuadLow(*args)
    def setSpfp(*args): return _riesling_n1_blaze.FloatRegisterFile_setSpfp(*args)
    def setFloat(*args): return _riesling_n1_blaze.FloatRegisterFile_setFloat(*args)
    def setDpfp(*args): return _riesling_n1_blaze.FloatRegisterFile_setDpfp(*args)
    def setDouble(*args): return _riesling_n1_blaze.FloatRegisterFile_setDouble(*args)
    def setQuadHigh(*args): return _riesling_n1_blaze.FloatRegisterFile_setQuadHigh(*args)
    def setQuadLow(*args): return _riesling_n1_blaze.FloatRegisterFile_setQuadLow(*args)

class FloatRegisterFilePtr(FloatRegisterFile):
    def __init__(self, this):
        _swig_setattr(self, FloatRegisterFile, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, FloatRegisterFile, 'thisown', 0)
        _swig_setattr(self, FloatRegisterFile,self.__class__,FloatRegisterFile)
_riesling_n1_blaze.FloatRegisterFile_swigregister(FloatRegisterFilePtr)

class V9_TrapType(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TrapType, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TrapType, name)
    def __repr__(self):
        return "<C Riesling::V9_TrapType instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, V9_TrapType, 'this', _riesling_n1_blaze.new_V9_TrapType(*args))
        _swig_setattr(self, V9_TrapType, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.V9_TrapType_toString(*args)
    def getTrapType(*args): return _riesling_n1_blaze.V9_TrapType_getTrapType(*args)
    def setTrapType(*args): return _riesling_n1_blaze.V9_TrapType_setTrapType(*args)

class V9_TrapTypePtr(V9_TrapType):
    def __init__(self, this):
        _swig_setattr(self, V9_TrapType, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_TrapType, 'thisown', 0)
        _swig_setattr(self, V9_TrapType,self.__class__,V9_TrapType)
_riesling_n1_blaze.V9_TrapType_swigregister(V9_TrapTypePtr)

class InstructionWord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, InstructionWord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, InstructionWord, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::InstructionWord instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.InstructionWord_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.InstructionWord_getNative(*args)
    def getPc(*args): return _riesling_n1_blaze.InstructionWord_getPc(*args)
    def getPpc(*args): return _riesling_n1_blaze.InstructionWord_getPpc(*args)

class InstructionWordPtr(InstructionWord):
    def __init__(self, this):
        _swig_setattr(self, InstructionWord, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, InstructionWord, 'thisown', 0)
        _swig_setattr(self, InstructionWord,self.__class__,InstructionWord)
_riesling_n1_blaze.InstructionWord_swigregister(InstructionWordPtr)

class Hv_InstructionWord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_InstructionWord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_InstructionWord, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_InstructionWord instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_InstructionWord_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_InstructionWord_getNative(*args)
    def getPc(*args): return _riesling_n1_blaze.Hv_InstructionWord_getPc(*args)
    def getPpc(*args): return _riesling_n1_blaze.Hv_InstructionWord_getPpc(*args)

class Hv_InstructionWordPtr(Hv_InstructionWord):
    def __init__(self, this):
        _swig_setattr(self, Hv_InstructionWord, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_InstructionWord, 'thisown', 0)
        _swig_setattr(self, Hv_InstructionWord,self.__class__,Hv_InstructionWord)
_riesling_n1_blaze.Hv_InstructionWord_swigregister(Hv_InstructionWordPtr)

class V9_TickReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TickReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TickReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_TickReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_TickReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_TickReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_TickReg_setNative(*args)

class V9_TickRegPtr(V9_TickReg):
    def __init__(self, this):
        _swig_setattr(self, V9_TickReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_TickReg, 'thisown', 0)
        _swig_setattr(self, V9_TickReg,self.__class__,V9_TickReg)
_riesling_n1_blaze.V9_TickReg_swigregister(V9_TickRegPtr)

class Sf_SoftIntReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_SoftIntReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_SoftIntReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Sf_SoftIntReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Sf_SoftIntReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Sf_SoftIntReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Sf_SoftIntReg_setNative(*args)

class Sf_SoftIntRegPtr(Sf_SoftIntReg):
    def __init__(self, this):
        _swig_setattr(self, Sf_SoftIntReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Sf_SoftIntReg, 'thisown', 0)
        _swig_setattr(self, Sf_SoftIntReg,self.__class__,Sf_SoftIntReg)
_riesling_n1_blaze.Sf_SoftIntReg_swigregister(Sf_SoftIntRegPtr)

class V9_TickCompareReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TickCompareReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TickCompareReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_TickCompareReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_TickCompareReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_TickCompareReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_TickCompareReg_setNative(*args)

class V9_TickCompareRegPtr(V9_TickCompareReg):
    def __init__(self, this):
        _swig_setattr(self, V9_TickCompareReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_TickCompareReg, 'thisown', 0)
        _swig_setattr(self, V9_TickCompareReg,self.__class__,V9_TickCompareReg)
_riesling_n1_blaze.V9_TickCompareReg_swigregister(V9_TickCompareRegPtr)

class V9_CcrReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_CcrReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_CcrReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_CcrReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_CcrReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_CcrReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_CcrReg_setNative(*args)

class V9_CcrRegPtr(V9_CcrReg):
    def __init__(self, this):
        _swig_setattr(self, V9_CcrReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_CcrReg, 'thisown', 0)
        _swig_setattr(self, V9_CcrReg,self.__class__,V9_CcrReg)
_riesling_n1_blaze.V9_CcrReg_swigregister(V9_CcrRegPtr)

class V9_YReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_YReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_YReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_YReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_YReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_YReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_YReg_setNative(*args)

class V9_YRegPtr(V9_YReg):
    def __init__(self, this):
        _swig_setattr(self, V9_YReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_YReg, 'thisown', 0)
        _swig_setattr(self, V9_YReg,self.__class__,V9_YReg)
_riesling_n1_blaze.V9_YReg_swigregister(V9_YRegPtr)

class V9_FprsReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_FprsReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_FprsReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_FprsReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_FprsReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_FprsReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_FprsReg_setNative(*args)

class V9_FprsRegPtr(V9_FprsReg):
    def __init__(self, this):
        _swig_setattr(self, V9_FprsReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_FprsReg, 'thisown', 0)
        _swig_setattr(self, V9_FprsReg,self.__class__,V9_FprsReg)
_riesling_n1_blaze.V9_FprsReg_swigregister(V9_FprsRegPtr)

class V9_FsrReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_FsrReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_FsrReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_FsrReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_FsrReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_FsrReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_FsrReg_setNative(*args)

class V9_FsrRegPtr(V9_FsrReg):
    def __init__(self, this):
        _swig_setattr(self, V9_FsrReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_FsrReg, 'thisown', 0)
        _swig_setattr(self, V9_FsrReg,self.__class__,V9_FsrReg)
_riesling_n1_blaze.V9_FsrReg_swigregister(V9_FsrRegPtr)

class V9_TbaReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TbaReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TbaReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_TbaReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_TbaReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_TbaReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_TbaReg_setNative(*args)

class V9_TbaRegPtr(V9_TbaReg):
    def __init__(self, this):
        _swig_setattr(self, V9_TbaReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_TbaReg, 'thisown', 0)
        _swig_setattr(self, V9_TbaReg,self.__class__,V9_TbaReg)
_riesling_n1_blaze.V9_TbaReg_swigregister(V9_TbaRegPtr)

class V9_PilReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_PilReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_PilReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_PilReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_PilReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_PilReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_PilReg_setNative(*args)

class V9_PilRegPtr(V9_PilReg):
    def __init__(self, this):
        _swig_setattr(self, V9_PilReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_PilReg, 'thisown', 0)
        _swig_setattr(self, V9_PilReg,self.__class__,V9_PilReg)
_riesling_n1_blaze.V9_PilReg_swigregister(V9_PilRegPtr)

class V9_AsiReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_AsiReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_AsiReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_AsiReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_AsiReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_AsiReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_AsiReg_setNative(*args)

class V9_AsiRegPtr(V9_AsiReg):
    def __init__(self, this):
        _swig_setattr(self, V9_AsiReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_AsiReg, 'thisown', 0)
        _swig_setattr(self, V9_AsiReg,self.__class__,V9_AsiReg)
_riesling_n1_blaze.V9_AsiReg_swigregister(V9_AsiRegPtr)

class V9_Tpc(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_Tpc, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_Tpc, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_Tpc instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_Tpc_toString(*args)
    def getTpc(*args): return _riesling_n1_blaze.V9_Tpc_getTpc(*args)
    def setTpc(*args): return _riesling_n1_blaze.V9_Tpc_setTpc(*args)
    def getMaxTl(*args): return _riesling_n1_blaze.V9_Tpc_getMaxTl(*args)

class V9_TpcPtr(V9_Tpc):
    def __init__(self, this):
        _swig_setattr(self, V9_Tpc, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_Tpc, 'thisown', 0)
        _swig_setattr(self, V9_Tpc,self.__class__,V9_Tpc)
_riesling_n1_blaze.V9_Tpc_swigregister(V9_TpcPtr)

class V9_Tnpc(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_Tnpc, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_Tnpc, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_Tnpc instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_Tnpc_toString(*args)
    def getTnpc(*args): return _riesling_n1_blaze.V9_Tnpc_getTnpc(*args)
    def setTnpc(*args): return _riesling_n1_blaze.V9_Tnpc_setTnpc(*args)

class V9_TnpcPtr(V9_Tnpc):
    def __init__(self, this):
        _swig_setattr(self, V9_Tnpc, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_Tnpc, 'thisown', 0)
        _swig_setattr(self, V9_Tnpc,self.__class__,V9_Tnpc)
_riesling_n1_blaze.V9_Tnpc_swigregister(V9_TnpcPtr)

class V9_WstateReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_WstateReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_WstateReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_WstateReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_WstateReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_WstateReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_WstateReg_setNative(*args)

class V9_WstateRegPtr(V9_WstateReg):
    def __init__(self, this):
        _swig_setattr(self, V9_WstateReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_WstateReg, 'thisown', 0)
        _swig_setattr(self, V9_WstateReg,self.__class__,V9_WstateReg)
_riesling_n1_blaze.V9_WstateReg_swigregister(V9_WstateRegPtr)

class V9_TrapLevelReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_TrapLevelReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_TrapLevelReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_TrapLevelReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_TrapLevelReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_TrapLevelReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_TrapLevelReg_setNative(*args)

class V9_TrapLevelRegPtr(V9_TrapLevelReg):
    def __init__(self, this):
        _swig_setattr(self, V9_TrapLevelReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_TrapLevelReg, 'thisown', 0)
        _swig_setattr(self, V9_TrapLevelReg,self.__class__,V9_TrapLevelReg)
_riesling_n1_blaze.V9_TrapLevelReg_swigregister(V9_TrapLevelRegPtr)

class V9_VerReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, V9_VerReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, V9_VerReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::V9_VerReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.V9_VerReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.V9_VerReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.V9_VerReg_setNative(*args)

class V9_VerRegPtr(V9_VerReg):
    def __init__(self, this):
        _swig_setattr(self, V9_VerReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, V9_VerReg, 'thisown', 0)
        _swig_setattr(self, V9_VerReg,self.__class__,V9_VerReg)
_riesling_n1_blaze.V9_VerReg_swigregister(V9_VerRegPtr)

class CMP_CoreAvailableReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreAvailableReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreAvailableReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_CoreAvailableReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_CoreAvailableReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_CoreAvailableReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_CoreAvailableReg_setNative(*args)
    def setAVAILABLE(*args): return _riesling_n1_blaze.CMP_CoreAvailableReg_setAVAILABLE(*args)

class CMP_CoreAvailableRegPtr(CMP_CoreAvailableReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_CoreAvailableReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_CoreAvailableReg, 'thisown', 0)
        _swig_setattr(self, CMP_CoreAvailableReg,self.__class__,CMP_CoreAvailableReg)
_riesling_n1_blaze.CMP_CoreAvailableReg_swigregister(CMP_CoreAvailableRegPtr)

class CMP_CoreEnabledReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreEnabledReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreEnabledReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_CoreEnabledReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_CoreEnabledReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_CoreEnabledReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_CoreEnabledReg_setNative(*args)
    def setENABLED(*args): return _riesling_n1_blaze.CMP_CoreEnabledReg_setENABLED(*args)

class CMP_CoreEnabledRegPtr(CMP_CoreEnabledReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_CoreEnabledReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_CoreEnabledReg, 'thisown', 0)
        _swig_setattr(self, CMP_CoreEnabledReg,self.__class__,CMP_CoreEnabledReg)
_riesling_n1_blaze.CMP_CoreEnabledReg_swigregister(CMP_CoreEnabledRegPtr)

class CMP_CoreEnableReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreEnableReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreEnableReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_CoreEnableReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_CoreEnableReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_CoreEnableReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_CoreEnableReg_setNative(*args)
    def setENABLE(*args): return _riesling_n1_blaze.CMP_CoreEnableReg_setENABLE(*args)

class CMP_CoreEnableRegPtr(CMP_CoreEnableReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_CoreEnableReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_CoreEnableReg, 'thisown', 0)
        _swig_setattr(self, CMP_CoreEnableReg,self.__class__,CMP_CoreEnableReg)
_riesling_n1_blaze.CMP_CoreEnableReg_swigregister(CMP_CoreEnableRegPtr)

class CMP_CoreRunningReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreRunningReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreRunningReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_CoreRunningReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_CoreRunningReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_CoreRunningReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_CoreRunningReg_setNative(*args)
    def setRUNNING(*args): return _riesling_n1_blaze.CMP_CoreRunningReg_setRUNNING(*args)

class CMP_CoreRunningRegPtr(CMP_CoreRunningReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_CoreRunningReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_CoreRunningReg, 'thisown', 0)
        _swig_setattr(self, CMP_CoreRunningReg,self.__class__,CMP_CoreRunningReg)
_riesling_n1_blaze.CMP_CoreRunningReg_swigregister(CMP_CoreRunningRegPtr)

class CMP_CoreRunningStatusReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CoreRunningStatusReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CoreRunningStatusReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_CoreRunningStatusReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_CoreRunningStatusReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_CoreRunningStatusReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_CoreRunningStatusReg_setNative(*args)
    def setRUNNING_STATUS(*args): return _riesling_n1_blaze.CMP_CoreRunningStatusReg_setRUNNING_STATUS(*args)

class CMP_CoreRunningStatusRegPtr(CMP_CoreRunningStatusReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_CoreRunningStatusReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_CoreRunningStatusReg, 'thisown', 0)
        _swig_setattr(self, CMP_CoreRunningStatusReg,self.__class__,CMP_CoreRunningStatusReg)
_riesling_n1_blaze.CMP_CoreRunningStatusReg_swigregister(CMP_CoreRunningStatusRegPtr)

class CMP_ErrorSteeringReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_ErrorSteeringReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_ErrorSteeringReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_ErrorSteeringReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_ErrorSteeringReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_ErrorSteeringReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_ErrorSteeringReg_setNative(*args)

class CMP_ErrorSteeringRegPtr(CMP_ErrorSteeringReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_ErrorSteeringReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_ErrorSteeringReg, 'thisown', 0)
        _swig_setattr(self, CMP_ErrorSteeringReg,self.__class__,CMP_ErrorSteeringReg)
_riesling_n1_blaze.CMP_ErrorSteeringReg_swigregister(CMP_ErrorSteeringRegPtr)

class CMP_XirSteeringReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_XirSteeringReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_XirSteeringReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_XirSteeringReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_XirSteeringReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.CMP_XirSteeringReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.CMP_XirSteeringReg_setNative(*args)

class CMP_XirSteeringRegPtr(CMP_XirSteeringReg):
    def __init__(self, this):
        _swig_setattr(self, CMP_XirSteeringReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_XirSteeringReg, 'thisown', 0)
        _swig_setattr(self, CMP_XirSteeringReg,self.__class__,CMP_XirSteeringReg)
_riesling_n1_blaze.CMP_XirSteeringReg_swigregister(CMP_XirSteeringRegPtr)

class CMP_CpuLevelCmpRegs(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, CMP_CpuLevelCmpRegs, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, CMP_CpuLevelCmpRegs, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::CMP_CpuLevelCmpRegs instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_toString(*args)
    def getCoreAvailableRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getCoreAvailableRegPtr(*args)
    def getCoreEnabledRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getCoreEnabledRegPtr(*args)
    def getCoreEnableRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getCoreEnableRegPtr(*args)
    def getCoreRunningRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getCoreRunningRegPtr(*args)
    def getCoreRunningStatusRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getCoreRunningStatusRegPtr(*args)
    def getErrorSteeringRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getErrorSteeringRegPtr(*args)
    def getXirSteeringRegPtr(*args): return _riesling_n1_blaze.CMP_CpuLevelCmpRegs_getXirSteeringRegPtr(*args)

class CMP_CpuLevelCmpRegsPtr(CMP_CpuLevelCmpRegs):
    def __init__(self, this):
        _swig_setattr(self, CMP_CpuLevelCmpRegs, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, CMP_CpuLevelCmpRegs, 'thisown', 0)
        _swig_setattr(self, CMP_CpuLevelCmpRegs,self.__class__,CMP_CpuLevelCmpRegs)
_riesling_n1_blaze.CMP_CpuLevelCmpRegs_swigregister(CMP_CpuLevelCmpRegsPtr)

class MemoryInterface(Object):
    __swig_setmethods__ = {}
    for _s in [Object]: __swig_setmethods__.update(_s.__swig_setmethods__)
    __setattr__ = lambda self, name, value: _swig_setattr(self, MemoryInterface, name, value)
    __swig_getmethods__ = {}
    for _s in [Object]: __swig_getmethods__.update(_s.__swig_getmethods__)
    __getattr__ = lambda self, name: _swig_getattr(self, MemoryInterface, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::MemoryInterface instance at %s>" % (self.this,)
    def read(*args): return _riesling_n1_blaze.MemoryInterface_read(*args)
    def write(*args): return _riesling_n1_blaze.MemoryInterface_write(*args)

class MemoryInterfacePtr(MemoryInterface):
    def __init__(self, this):
        _swig_setattr(self, MemoryInterface, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, MemoryInterface, 'thisown', 0)
        _swig_setattr(self, MemoryInterface,self.__class__,MemoryInterface)
_riesling_n1_blaze.MemoryInterface_swigregister(MemoryInterfacePtr)

class SparseMemory(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, SparseMemory, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, SparseMemory, name)
    def __repr__(self):
        return "<C Riesling::SparseMemory instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, SparseMemory, 'this', _riesling_n1_blaze.new_SparseMemory(*args))
        _swig_setattr(self, SparseMemory, 'thisown', 1)
    def read32(*args): return _riesling_n1_blaze.SparseMemory_read32(*args)
    def read64(*args): return _riesling_n1_blaze.SparseMemory_read64(*args)
    def write32(*args): return _riesling_n1_blaze.SparseMemory_write32(*args)
    def write64(*args): return _riesling_n1_blaze.SparseMemory_write64(*args)
    def pageCount(*args): return _riesling_n1_blaze.SparseMemory_pageCount(*args)

class SparseMemoryPtr(SparseMemory):
    def __init__(self, this):
        _swig_setattr(self, SparseMemory, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, SparseMemory, 'thisown', 0)
        _swig_setattr(self, SparseMemory,self.__class__,SparseMemory)
_riesling_n1_blaze.SparseMemory_swigregister(SparseMemoryPtr)

class BreakpointTable(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, BreakpointTable, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, BreakpointTable, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::BreakpointTable instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.BreakpointTable_toString(*args)
    def add(*args): return _riesling_n1_blaze.BreakpointTable_add(*args)
    def remove(*args): return _riesling_n1_blaze.BreakpointTable_remove(*args)
    def enable(*args): return _riesling_n1_blaze.BreakpointTable_enable(*args)
    def disable(*args): return _riesling_n1_blaze.BreakpointTable_disable(*args)
    def list(*args): return _riesling_n1_blaze.BreakpointTable_list(*args)
    def query(*args): return _riesling_n1_blaze.BreakpointTable_query(*args)
    def querySid(*args): return _riesling_n1_blaze.BreakpointTable_querySid(*args)
    def isBadTrap(*args): return _riesling_n1_blaze.BreakpointTable_isBadTrap(*args)

class BreakpointTablePtr(BreakpointTable):
    def __init__(self, this):
        _swig_setattr(self, BreakpointTable, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, BreakpointTable, 'thisown', 0)
        _swig_setattr(self, BreakpointTable,self.__class__,BreakpointTable)
_riesling_n1_blaze.BreakpointTable_swigregister(BreakpointTablePtr)

class Ni_IDPartitionIdReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_IDPartitionIdReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_IDPartitionIdReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_IDPartitionIdReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_IDPartitionIdReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Ni_IDPartitionIdReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Ni_IDPartitionIdReg_setNative(*args)

class Ni_IDPartitionIdRegPtr(Ni_IDPartitionIdReg):
    def __init__(self, this):
        _swig_setattr(self, Ni_IDPartitionIdReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_IDPartitionIdReg, 'thisown', 0)
        _swig_setattr(self, Ni_IDPartitionIdReg,self.__class__,Ni_IDPartitionIdReg)
_riesling_n1_blaze.Ni_IDPartitionIdReg_swigregister(Ni_IDPartitionIdRegPtr)

class Sf_ContextReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_ContextReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_ContextReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Sf_ContextReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Sf_ContextReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Sf_ContextReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Sf_ContextReg_setNative(*args)

class Sf_ContextRegPtr(Sf_ContextReg):
    def __init__(self, this):
        _swig_setattr(self, Sf_ContextReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Sf_ContextReg, 'thisown', 0)
        _swig_setattr(self, Sf_ContextReg,self.__class__,Sf_ContextReg)
_riesling_n1_blaze.Sf_ContextReg_swigregister(Sf_ContextRegPtr)

class Sf_TagTargetReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_TagTargetReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_TagTargetReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Sf_TagTargetReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Sf_TagTargetReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Sf_TagTargetReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Sf_TagTargetReg_setNative(*args)

class Sf_TagTargetRegPtr(Sf_TagTargetReg):
    def __init__(self, this):
        _swig_setattr(self, Sf_TagTargetReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Sf_TagTargetReg, 'thisown', 0)
        _swig_setattr(self, Sf_TagTargetReg,self.__class__,Sf_TagTargetReg)
_riesling_n1_blaze.Sf_TagTargetReg_swigregister(Sf_TagTargetRegPtr)

class Sf_TagAccessReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Sf_TagAccessReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Sf_TagAccessReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Sf_TagAccessReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Sf_TagAccessReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Sf_TagAccessReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Sf_TagAccessReg_setNative(*args)

class Sf_TagAccessRegPtr(Sf_TagAccessReg):
    def __init__(self, this):
        _swig_setattr(self, Sf_TagAccessReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Sf_TagAccessReg, 'thisown', 0)
        _swig_setattr(self, Sf_TagAccessReg,self.__class__,Sf_TagAccessReg)
_riesling_n1_blaze.Sf_TagAccessReg_swigregister(Sf_TagAccessRegPtr)

class Ni_Mmu(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Mmu, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Mmu, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_Mmu instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_Mmu_toString(*args)

class Ni_MmuPtr(Ni_Mmu):
    def __init__(self, this):
        _swig_setattr(self, Ni_Mmu, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_Mmu, 'thisown', 0)
        _swig_setattr(self, Ni_Mmu,self.__class__,Ni_Mmu)
_riesling_n1_blaze.Ni_Mmu_swigregister(Ni_MmuPtr)

class Ni_InstructionWord(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_InstructionWord, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_InstructionWord, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_InstructionWord instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_InstructionWord_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Ni_InstructionWord_getNative(*args)
    def getPc(*args): return _riesling_n1_blaze.Ni_InstructionWord_getPc(*args)
    def getPpc(*args): return _riesling_n1_blaze.Ni_InstructionWord_getPpc(*args)

class Ni_InstructionWordPtr(Ni_InstructionWord):
    def __init__(self, this):
        _swig_setattr(self, Ni_InstructionWord, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_InstructionWord, 'thisown', 0)
        _swig_setattr(self, Ni_InstructionWord,self.__class__,Ni_InstructionWord)
_riesling_n1_blaze.Ni_InstructionWord_swigregister(Ni_InstructionWordPtr)

class Ni_TstateEntry(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_TstateEntry, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_TstateEntry, name)
    def __repr__(self):
        return "<C Riesling::Ni_TstateEntry instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, Ni_TstateEntry, 'this', _riesling_n1_blaze.new_Ni_TstateEntry(*args))
        _swig_setattr(self, Ni_TstateEntry, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.Ni_TstateEntry_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Ni_TstateEntry_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Ni_TstateEntry_setNative(*args)

class Ni_TstateEntryPtr(Ni_TstateEntry):
    def __init__(self, this):
        _swig_setattr(self, Ni_TstateEntry, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_TstateEntry, 'thisown', 0)
        _swig_setattr(self, Ni_TstateEntry,self.__class__,Ni_TstateEntry)
_riesling_n1_blaze.Ni_TstateEntry_swigregister(Ni_TstateEntryPtr)

class Ni_Tstate(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Tstate, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Tstate, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_Tstate instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_Tstate_toString(*args)
    def getTstateEntry(*args): return _riesling_n1_blaze.Ni_Tstate_getTstateEntry(*args)
    def setTstateEntry(*args): return _riesling_n1_blaze.Ni_Tstate_setTstateEntry(*args)

class Ni_TstatePtr(Ni_Tstate):
    def __init__(self, this):
        _swig_setattr(self, Ni_Tstate, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_Tstate, 'thisown', 0)
        _swig_setattr(self, Ni_Tstate,self.__class__,Ni_Tstate)
_riesling_n1_blaze.Ni_Tstate_swigregister(Ni_TstatePtr)

class Ni_PstateReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_PstateReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_PstateReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_PstateReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_PstateReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Ni_PstateReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Ni_PstateReg_setNative(*args)

class Ni_PstateRegPtr(Ni_PstateReg):
    def __init__(self, this):
        _swig_setattr(self, Ni_PstateReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_PstateReg, 'thisown', 0)
        _swig_setattr(self, Ni_PstateReg,self.__class__,Ni_PstateReg)
_riesling_n1_blaze.Ni_PstateReg_swigregister(Ni_PstateRegPtr)

class Hv_HtstateEntry(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HtstateEntry, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HtstateEntry, name)
    def __repr__(self):
        return "<C Riesling::Hv_HtstateEntry instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, Hv_HtstateEntry, 'this', _riesling_n1_blaze.new_Hv_HtstateEntry(*args))
        _swig_setattr(self, Hv_HtstateEntry, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.Hv_HtstateEntry_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_HtstateEntry_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_HtstateEntry_setNative(*args)

class Hv_HtstateEntryPtr(Hv_HtstateEntry):
    def __init__(self, this):
        _swig_setattr(self, Hv_HtstateEntry, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_HtstateEntry, 'thisown', 0)
        _swig_setattr(self, Hv_HtstateEntry,self.__class__,Hv_HtstateEntry)
_riesling_n1_blaze.Hv_HtstateEntry_swigregister(Hv_HtstateEntryPtr)

class Hv_Htstate(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_Htstate, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_Htstate, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_Htstate instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_Htstate_toString(*args)
    def getHtstateEntry(*args): return _riesling_n1_blaze.Hv_Htstate_getHtstateEntry(*args)
    def setHtstateEntry(*args): return _riesling_n1_blaze.Hv_Htstate_setHtstateEntry(*args)
    def getMaxTl(*args): return _riesling_n1_blaze.Hv_Htstate_getMaxTl(*args)

class Hv_HtstatePtr(Hv_Htstate):
    def __init__(self, this):
        _swig_setattr(self, Hv_Htstate, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_Htstate, 'thisown', 0)
        _swig_setattr(self, Hv_Htstate,self.__class__,Hv_Htstate)
_riesling_n1_blaze.Hv_Htstate_swigregister(Hv_HtstatePtr)

class Vis2_GsrReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Vis2_GsrReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Vis2_GsrReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Vis2_GsrReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Vis2_GsrReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Vis2_GsrReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Vis2_GsrReg_setNative(*args)

class Vis2_GsrRegPtr(Vis2_GsrReg):
    def __init__(self, this):
        _swig_setattr(self, Vis2_GsrReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Vis2_GsrReg, 'thisown', 0)
        _swig_setattr(self, Vis2_GsrReg,self.__class__,Vis2_GsrReg)
_riesling_n1_blaze.Vis2_GsrReg_swigregister(Vis2_GsrRegPtr)

class Hv_HpstateReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HpstateReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HpstateReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_HpstateReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_HpstateReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_HpstateReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_HpstateReg_setNative(*args)

class Hv_HpstateRegPtr(Hv_HpstateReg):
    def __init__(self, this):
        _swig_setattr(self, Hv_HpstateReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_HpstateReg, 'thisown', 0)
        _swig_setattr(self, Hv_HpstateReg,self.__class__,Hv_HpstateReg)
_riesling_n1_blaze.Hv_HpstateReg_swigregister(Hv_HpstateRegPtr)

class Hv_HtbaReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HtbaReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HtbaReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_HtbaReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_HtbaReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_HtbaReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_HtbaReg_setNative(*args)

class Hv_HtbaRegPtr(Hv_HtbaReg):
    def __init__(self, this):
        _swig_setattr(self, Hv_HtbaReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_HtbaReg, 'thisown', 0)
        _swig_setattr(self, Hv_HtbaReg,self.__class__,Hv_HtbaReg)
_riesling_n1_blaze.Hv_HtbaReg_swigregister(Hv_HtbaRegPtr)

class Ni_HverReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_HverReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_HverReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_HverReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_HverReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Ni_HverReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Ni_HverReg_setNative(*args)

class Ni_HverRegPtr(Ni_HverReg):
    def __init__(self, this):
        _swig_setattr(self, Ni_HverReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_HverReg, 'thisown', 0)
        _swig_setattr(self, Ni_HverReg,self.__class__,Ni_HverReg)
_riesling_n1_blaze.Ni_HverReg_swigregister(Ni_HverRegPtr)

class Hv_HintpReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HintpReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HintpReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_HintpReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_HintpReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_HintpReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_HintpReg_setNative(*args)

class Hv_HintpRegPtr(Hv_HintpReg):
    def __init__(self, this):
        _swig_setattr(self, Hv_HintpReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_HintpReg, 'thisown', 0)
        _swig_setattr(self, Hv_HintpReg,self.__class__,Hv_HintpReg)
_riesling_n1_blaze.Hv_HintpReg_swigregister(Hv_HintpRegPtr)

class Hv_HstickCompareReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_HstickCompareReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_HstickCompareReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_HstickCompareReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_HstickCompareReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_HstickCompareReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_HstickCompareReg_setNative(*args)

class Hv_HstickCompareRegPtr(Hv_HstickCompareReg):
    def __init__(self, this):
        _swig_setattr(self, Hv_HstickCompareReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_HstickCompareReg, 'thisown', 0)
        _swig_setattr(self, Hv_HstickCompareReg,self.__class__,Hv_HstickCompareReg)
_riesling_n1_blaze.Hv_HstickCompareReg_swigregister(Hv_HstickCompareRegPtr)

class Hv_GlobalLevelReg(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_GlobalLevelReg, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_GlobalLevelReg, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_GlobalLevelReg instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_GlobalLevelReg_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_GlobalLevelReg_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_GlobalLevelReg_setNative(*args)

class Hv_GlobalLevelRegPtr(Hv_GlobalLevelReg):
    def __init__(self, this):
        _swig_setattr(self, Hv_GlobalLevelReg, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_GlobalLevelReg, 'thisown', 0)
        _swig_setattr(self, Hv_GlobalLevelReg,self.__class__,Hv_GlobalLevelReg)
_riesling_n1_blaze.Hv_GlobalLevelReg_swigregister(Hv_GlobalLevelRegPtr)

class Hv_ScratchPad(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Hv_ScratchPad, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Hv_ScratchPad, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Hv_ScratchPad instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Hv_ScratchPad_toString(*args)
    def getNative(*args): return _riesling_n1_blaze.Hv_ScratchPad_getNative(*args)
    def setNative(*args): return _riesling_n1_blaze.Hv_ScratchPad_setNative(*args)

class Hv_ScratchPadPtr(Hv_ScratchPad):
    def __init__(self, this):
        _swig_setattr(self, Hv_ScratchPad, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Hv_ScratchPad, 'thisown', 0)
        _swig_setattr(self, Hv_ScratchPad,self.__class__,Hv_ScratchPad)
_riesling_n1_blaze.Hv_ScratchPad_swigregister(Hv_ScratchPadPtr)

class Ni_ArchState(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_ArchState, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_ArchState, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_ArchState instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_ArchState_toString(*args)
    def getPc(*args): return _riesling_n1_blaze.Ni_ArchState_getPc(*args)
    def setPc(*args): return _riesling_n1_blaze.Ni_ArchState_setPc(*args)
    def getNpc(*args): return _riesling_n1_blaze.Ni_ArchState_getNpc(*args)
    def setNpc(*args): return _riesling_n1_blaze.Ni_ArchState_setNpc(*args)
    def getRegisterFilePtr(*args): return _riesling_n1_blaze.Ni_ArchState_getRegisterFilePtr(*args)
    def getFloatRegisterFilePtr(*args): return _riesling_n1_blaze.Ni_ArchState_getFloatRegisterFilePtr(*args)
    def getTstateRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTstateRegPtr(*args)
    def getPstateRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getPstateRegPtr(*args)
    def getHtstateRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getHtstateRegPtr(*args)
    def getGsrRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getGsrRegPtr(*args)
    def getHpstateRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getHpstateRegPtr(*args)
    def getHtbaRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getHtbaRegPtr(*args)
    def getHverRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getHverRegPtr(*args)
    def getHintpRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getHintpRegPtr(*args)
    def getHstickCompareRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getHstickCompareRegPtr(*args)
    def getGlobalLevelRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getGlobalLevelRegPtr(*args)
    def getScratchPadPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getScratchPadPtr(*args)
    def getStickRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getStickRegPtr(*args)
    def getSoftIntRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getSoftIntRegPtr(*args)
    def getTickCmprRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTickCmprRegPtr(*args)
    def getStickCmprRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getStickCmprRegPtr(*args)
    def getCcrRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getCcrRegPtr(*args)
    def getYRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getYRegPtr(*args)
    def getFprsRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getFprsRegPtr(*args)
    def getFsrRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getFsrRegPtr(*args)
    def getTickRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTickRegPtr(*args)
    def getTbaRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTbaRegPtr(*args)
    def getPilRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getPilRegPtr(*args)
    def getAsiRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getAsiRegPtr(*args)
    def getTpcRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTpcRegPtr(*args)
    def getTnpcRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTnpcRegPtr(*args)
    def getWstateRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getWstateRegPtr(*args)
    def getTrapLevelRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTrapLevelRegPtr(*args)
    def getVerRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getVerRegPtr(*args)
    def getTrapTypeRegPtr(*args): return _riesling_n1_blaze.Ni_ArchState_getTrapTypeRegPtr(*args)

class Ni_ArchStatePtr(Ni_ArchState):
    def __init__(self, this):
        _swig_setattr(self, Ni_ArchState, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_ArchState, 'thisown', 0)
        _swig_setattr(self, Ni_ArchState,self.__class__,Ni_ArchState)
_riesling_n1_blaze.Ni_ArchState_swigregister(Ni_ArchStatePtr)

class Ni_Strand(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Strand, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Strand, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_Strand instance at %s>" % (self.this,)
    def step(*args): return _riesling_n1_blaze.Ni_Strand_step(*args)
    def getArchStatePtr(*args): return _riesling_n1_blaze.Ni_Strand_getArchStatePtr(*args)
    def getMmuPtr(*args): return _riesling_n1_blaze.Ni_Strand_getMmuPtr(*args)
    def lastInstr(*args): return _riesling_n1_blaze.Ni_Strand_lastInstr(*args)
    def lastInstrToString(*args): return _riesling_n1_blaze.Ni_Strand_lastInstrToString(*args)
    def RS_getInstrPtr(*args): return _riesling_n1_blaze.Ni_Strand_RS_getInstrPtr(*args)
    def RS_translate(*args): return _riesling_n1_blaze.Ni_Strand_RS_translate(*args)
    def RS_access(*args): return _riesling_n1_blaze.Ni_Strand_RS_access(*args)
    def RS_asiRead(*args): return _riesling_n1_blaze.Ni_Strand_RS_asiRead(*args)
    def RS_asiWrite(*args): return _riesling_n1_blaze.Ni_Strand_RS_asiWrite(*args)

class Ni_StrandPtr(Ni_Strand):
    def __init__(self, this):
        _swig_setattr(self, Ni_Strand, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_Strand, 'thisown', 0)
        _swig_setattr(self, Ni_Strand,self.__class__,Ni_Strand)
_riesling_n1_blaze.Ni_Strand_swigregister(Ni_StrandPtr)

class Ni_Core(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Core, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Core, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_Core instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_Core_toString(*args)
    def getNStrands(*args): return _riesling_n1_blaze.Ni_Core_getNStrands(*args)
    def getStrandPtr(*args): return _riesling_n1_blaze.Ni_Core_getStrandPtr(*args)

class Ni_CorePtr(Ni_Core):
    def __init__(self, this):
        _swig_setattr(self, Ni_Core, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_Core, 'thisown', 0)
        _swig_setattr(self, Ni_Core,self.__class__,Ni_Core)
_riesling_n1_blaze.Ni_Core_swigregister(Ni_CorePtr)

class Ni_Cpu(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_Cpu, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_Cpu, name)
    def __init__(self): raise RuntimeError, "No constructor defined"
    def __repr__(self):
        return "<C Riesling::Ni_Cpu instance at %s>" % (self.this,)
    def toString(*args): return _riesling_n1_blaze.Ni_Cpu_toString(*args)
    def getNCores(*args): return _riesling_n1_blaze.Ni_Cpu_getNCores(*args)
    def getCorePtr(*args): return _riesling_n1_blaze.Ni_Cpu_getCorePtr(*args)

class Ni_CpuPtr(Ni_Cpu):
    def __init__(self, this):
        _swig_setattr(self, Ni_Cpu, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_Cpu, 'thisown', 0)
        _swig_setattr(self, Ni_Cpu,self.__class__,Ni_Cpu)
_riesling_n1_blaze.Ni_Cpu_swigregister(Ni_CpuPtr)

class Ni_System(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Ni_System, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Ni_System, name)
    def __repr__(self):
        return "<C Riesling::Ni_System instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, Ni_System, 'this', _riesling_n1_blaze.new_Ni_System(*args))
        _swig_setattr(self, Ni_System, 'thisown', 1)
    def toString(*args): return _riesling_n1_blaze.Ni_System_toString(*args)
    def getNCpus(*args): return _riesling_n1_blaze.Ni_System_getNCpus(*args)
    def getCpuPtr(*args): return _riesling_n1_blaze.Ni_System_getCpuPtr(*args)
    def loadMemdatImage(*args): return _riesling_n1_blaze.Ni_System_loadMemdatImage(*args)
    def getRam(*args): return _riesling_n1_blaze.Ni_System_getRam(*args)
    def getThisPtr(*args): return _riesling_n1_blaze.Ni_System_getThisPtr(*args)
    def getBreakpointTablePtr(*args): return _riesling_n1_blaze.Ni_System_getBreakpointTablePtr(*args)

class Ni_SystemPtr(Ni_System):
    def __init__(self, this):
        _swig_setattr(self, Ni_System, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Ni_System, 'thisown', 0)
        _swig_setattr(self, Ni_System,self.__class__,Ni_System)
_riesling_n1_blaze.Ni_System_swigregister(Ni_SystemPtr)

class Blaze_Ni_System(_object):
    __swig_setmethods__ = {}
    __setattr__ = lambda self, name, value: _swig_setattr(self, Blaze_Ni_System, name, value)
    __swig_getmethods__ = {}
    __getattr__ = lambda self, name: _swig_getattr(self, Blaze_Ni_System, name)
    def __repr__(self):
        return "<C Riesling::Blaze_Ni_System instance at %s>" % (self.this,)
    def __init__(self, *args):
        _swig_setattr(self, Blaze_Ni_System, 'this', _riesling_n1_blaze.new_Blaze_Ni_System(*args))
        _swig_setattr(self, Blaze_Ni_System, 'thisown', 1)
    def getNCpus(*args): return _riesling_n1_blaze.Blaze_Ni_System_getNCpus(*args)
    def getCpuPtr(*args): return _riesling_n1_blaze.Blaze_Ni_System_getCpuPtr(*args)
    def getThisPtr(*args): return _riesling_n1_blaze.Blaze_Ni_System_getThisPtr(*args)
    def getBreakpointTablePtr(*args): return _riesling_n1_blaze.Blaze_Ni_System_getBreakpointTablePtr(*args)

class Blaze_Ni_SystemPtr(Blaze_Ni_System):
    def __init__(self, this):
        _swig_setattr(self, Blaze_Ni_System, 'this', this)
        if not hasattr(self,"thisown"): _swig_setattr(self, Blaze_Ni_System, 'thisown', 0)
        _swig_setattr(self, Blaze_Ni_System,self.__class__,Blaze_Ni_System)
_riesling_n1_blaze.Blaze_Ni_System_swigregister(Blaze_Ni_SystemPtr)


