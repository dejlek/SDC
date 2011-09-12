/**
 * Copyright 2010-2011 Bernard Helyer.
 * Copyright 2010 Jakob Ovrum.
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */
module sdc.gen.type;

import std.algorithm;
import std.conv;
import std.string;
import std.range;

import llvm.c.Core;

import sdc.aglobal;
import sdc.util;
import sdc.compilererror;
import sdc.location;
import sdc.extract;
import ast = sdc.ast.all;
import sdc.gen.sdcmodule;
import sdc.gen.value;
import sdc.gen.sdcfunction;


enum DType
{
    None,
    Void,
    Bool,
    Char,
    Ubyte,
    Byte,
    Wchar,
    Ushort,
    Short,
    Dchar,
    Uint,
    Int,
    Ulong,
    Long,
    Float,
    Double,
    Real,
    NullPointer,
    Pointer,
    Array,
    StaticArray,
    Const,
    Immutable,
    Complex,
    Struct,
    Enum,
    Class,
    Inferred,
    Scope,
    Function,
}

version (none) Type dtypeToType(DType dtype, Module mod)
{
    final switch (dtype) with (DType) {
    case None:
        break;
    case Void:
        return new VoidType(mod);
    case Bool:
        return new BoolType(mod);
    case Char:
        return new CharType(mod);
    case Ubyte:
        return new UbyteType(mod);
    case Byte:
        return new ByteType(mod);
    case Wchar:
        return new WcharType(mod);
    case Ushort:
        return new UshortType(mod);
    case Short:
        return new ShortType(mod);
    case Dchar:
        return new DcharType(mod);
    case Uint:
        return new UintType(mod);
    case Int:
        return new IntType(mod);
    case Ulong:
        return new UlongType(mod);
    case Long:
        return new LongType(mod); 
    case Float:
        return new FloatType(mod);
    case Double:
        return new DoubleType(mod);
    case Real:
        return new RealType(mod);
    case NullPointer:
    case Pointer:
    case Array:
    case Complex:
    case Struct:
    case Enum:
    case Class:
    case Const:
    case Immutable:
    case Scope:
    case Function:
        break;
    case Inferred:
        return new InferredType(mod);
    }
    throw new CompilerPanic("tried to get Type out of invalid DType '" ~ to!string(dtype) ~ "'");
}

pure bool isComplexDType(DType dtype)
{
    return dtype >= DType.Complex;
}

pure bool isIntegerDType(DType dtype)
{
    return dtype >= DType.Bool && dtype <= DType.Long;
}

pure bool isFPDtype(DType dtype)
{
    return dtype >= DType.Float && dtype <= DType.Double;
}

abstract class Type
{
    DType dtype;
    ast.Access access;
    bool isRef = false;
    Scope typeScope;
    size_t stillToGo;
    string[] aliasThises;
    
    this(Module mod)
    {
        mModule = mod;
        access = mod.currentAccess;
        typeScope = new Scope();
    }
    
    LLVMTypeRef llvmType()
    {
        return mType;
    }
    
    /// An opEquals appropriate for simple types.
    override bool opEquals(Object o)
    {
        auto asType = cast(Type) o;
        if (!asType) return false;
        
        return this.mType == asType.mType;
    }
    
    abstract Value getValue(Module mod, Location location);
    
    Type getBase()
    {
        throw new CompilerPanic(
            format(`tried to get base type of type "%s"`, name())
        );
    }
    
    ast.QualifiedName getFullName()
    {
        throw new CompilerPanic(
            format(`tried to get full name of type "%s"`, name())
        );
    }
    
    Type importToModule(Module mod)
    {
        return this;
    }
    
    abstract string name();
    
    // Override this for complex types.
    bool equals(Type other)
    {
        debug if(isComplexDType(dtype)) {
            throw new CompilerPanic(format("complex type '%s' does not override Type.equals.", name()));
        }
        return dtype == other.dtype;
    }
    
    package   Module mModule;
    protected LLVMTypeRef mType;
}

class ScopeType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Scope;
    }
    
    override Value getValue(Module mod, Location location)
    {
        throw new CompilerPanic(location, "attempted to getValue a ScopeType.");
    }
    
    override string name() { return "scope"; }
}

class VoidType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Void;
        mType = LLVMVoidTypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new VoidValue(mod, location);
    }
    
    override string name() { return "void"; }
}

class BoolType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Bool;
        mType = LLVMInt1TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    { 
        return new BoolValue(mod, location);
    }
    
    override string name() { return "bool"; }
}

class ByteType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Byte;
        mType = LLVMInt8TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ByteValue(mod, location);
    }
    
    override string name() { return "byte"; }
}

class UbyteType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Ubyte;
        mType = LLVMInt8TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UbyteValue(mod, location);
    }
    
    override string name() { return "ubyte"; }
}

class ShortType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Short;
        mType = LLVMInt16TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ShortValue(mod, location);
    }
    
    override string name() { return "short"; }
}

class UshortType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Ushort;
        mType = LLVMInt16TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UshortValue(mod, location);
    }
    
    override string name() { return "ushort"; }
}

class IntType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Int;
        mType = LLVMInt32TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new IntValue(mod, location);
    }
    
    override string name() { return "int"; }
    
    override Type importToModule(Module mod) { return new IntType(mod); }
}

class UintType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Uint;
        mType = LLVMInt32TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UintValue(mod, location);
    }
    
    override string name() { return "uint"; }
}

class LongType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Long;
        mType = LLVMInt64TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new LongValue(mod, location);
    }
    
    override string name() { return "long"; }
}

class UlongType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Ulong;
        mType = LLVMInt64TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new UlongValue(mod, location);
    }
    
    override string name() { return "ulong"; }
}

class FloatType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Float;
        mType = LLVMFloatTypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new FloatValue(mod, location);
    }
    
    override string name() { return "float"; }
}

class DoubleType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Double;
        mType = LLVMDoubleTypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new DoubleValue(mod, location);
    }
    
    override string name() { return "double"; }
}

class RealType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Real;
        mType = LLVMFP128TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new RealValue(mod, location);
    }
    
    override string name() { return "real"; }
}

class CharType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Char;
        mType = LLVMInt8TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new CharValue(mod, location);
    }
    
    override string name() { return "char"; }
}

class WcharType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Wchar;
        mType = LLVMInt16TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new WcharValue(mod, location);
    }
    
    override string name() { return "wchar"; }
}

class DcharType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Dchar;
        mType = LLVMInt32TypeInContext(mod.context);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new DcharValue(mod, location);
    }
    
    override string name() { return "dchar"; }
}

class PointerType : Type
{
    private Type base;
    
    this(Module mod, Type base)
    {
        super(mod);
        this.base = base;
        dtype = DType.Pointer;
        if (base !is null) {
            if (base.dtype == DType.Void) {
                init(LLVMInt8TypeInContext(mod.context));
            } else {
                init(base.llvmType);
            }
        }
    }
    
    void init(LLVMTypeRef t)
    {
        mType = LLVMPointerType(t, 0);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new PointerValue(mod, location, base);
    }
    
    override Type getBase()
    {
        return base;
    }
    
    override string name()
    {
        if (base.dtype == DType.Function) {
            auto fnType = cast(FunctionType) getBase();
            return fnType.toString(FunctionType.ToStringType.FunctionPointer);
        } else {
            return base.name() ~ '*';
        }
    }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Pointer) {
            return false;
        }
        
        return base.equals(other.getBase());
    }
}

class ConstType : Type
{
    private Type base;
    
    this(Module mod, Type base)
    {
        super(mod);
        this.base = base;
        dtype = DType.Const;
        mType = base.mType;
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ConstValue(mod, location, base.getValue(mod, location));
    }
    
    override Type getBase()
    {
        return base;
    }
    
    override string name() { return "const(" ~ base.name() ~ ")"; }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Const) {
            return false;
        }
        
        return base.equals(other.getBase());
    }
}

class ImmutableType : Type
{
    private Type base;
    
    this(Module mod, Type base)
    {
        super(mod);
        dtype = DType.Immutable;
        this.base = base;
        mType = base.mType;
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ImmutableValue(mod, location, base.getValue(mod, location));
    }
    
    override Type getBase()
    {
        return base;
    }
    
    override string name() { return "immutable(" ~ base.name() ~ ")"; }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Immutable) {
            return false;
        }
        
        return base.equals(other.getBase());
    }
}

struct Field
{
    string name;
    Type type;
    
    Field importToModule(Module mod)
    {
        return Field(name, type.importToModule(mod));
    }
}

struct Method
{
    string name;
    Function fn;
    
    Method importToModule(Module mod)
    {
        return Method(name, fn.importToModule(mod));
    }
}

class ClassType : Type
{
    ast.QualifiedName fullName;
    StructType structType;
    ClassType parent;  // Optional for object.Object.
    
    Field[] fields;
    Method[] methods;
    size_t[string] methodIndices;
    
    this(Module mod, ClassType parent)
    {
        super(mod);
        dtype = DType.Class;
        this.parent = parent;
        this.fields = fields;
        this.methods = methods;
        
        structType = new StructType(mod);
        structType.addMemberVar("__vptr", new PointerType(mod, new PointerType(mod, new VoidType(mod))));
        structType.addMemberVar("__monitor", new PointerType(mod, new VoidType(mod)));
        addParentsFields();
        addParentsMethods();
    }
    
    this(Module mod)
    {
        super(mod);
        dtype = DType.Class;
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new ClassValue(mod, location, this);
    }
    
    override ast.QualifiedName getFullName()
    {
        return fullName;
    }
    
    override string name()
    {
        return "class " ~ extractQualifiedName(fullName);
    }
    
    void declare()
    {
        structType.declare();
        mType = (new PointerType(mModule, structType)).llvmType;
    }
    
    void addMemberVar(string name, Type t)
    {
        fields ~= Field(name, t);
        structType.addMemberVar(name, t);
    }
    
    void addMemberFunction(string name, Function fn)
    {
        if (auto p = name in methodIndices) {
            methods[*p] = Method(name, fn);
        } else {
            addMethod(Method(name, fn));
        }
        mModule.globalScope.add(name, new Store(fn, Location()));
    }
    
    /// Add the parents' non-static fields, from least to most derived.
    protected void addParentsFields()
    {
        auto currentParent = parent;
        while (currentParent !is null) {
            addFields(currentParent.fields);
            currentParent = currentParent.parent;
        }
    }
    
    /// Add the parents' methods, from most to least derived.  
    protected void addParentsMethods()
    {
        auto currentParent = parent;
        ClassType[] parents;
        while (currentParent !is null) {
            parents ~= currentParent;
            currentParent = currentParent.parent;
        }
        
        foreach (cparent; retro(parents)) {
            addMethods(cparent.methods);
        }
    }
    
    protected void addFields(Field[] fields)
    {
        this.fields ~= fields; 
        foreach (field; fields) {
            structType.addMemberVar(field.name, field.type);
        }
    }
    
    protected void addMethods(Method[] methods)
    {
        foreach (method; methods) addMethod(method);
    }
    
    protected void addMethod(Method method)
    {
        this.methods ~= method;
        methodIndices[method.name] = methods.length - 1; 
    }
    
    protected ClassType importParent(Module mod)
    {
        if (parent is null) {
            return null;
        }
        return parent.importToModule(mod);
    }
    
    override ClassType importToModule(Module mod)
    {
        static Type[Module] importCache;
        if (auto p = mod in importCache) {
            return *p;
        }
        
        auto type = new ClassType(mod);
        importCache[mod] = type;
        
        type.fullName = fullName;
        if (parent !is null) type.parent = cast(ClassType) parent.importToModule(mod);
        type.structType = cast(StructType) structType.importToModule(mod);
        type.fields = importList(fields, mod);
        type.declare();
        type.methods = importList(methods, mod);
        foreach (k, v; methodIndices) {
            type.methodIndices[k] = v;
        }
        
        return type; 
    }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Class) {
            return false;
        }
        
        return fullName == other.getFullName();
    }
}

/*
 * This is not the same as a default initialised void*.
 * It's treated as a distinct type as D treats nulls 
 * special (they can be implicitly converted to any pointer
 * type). Just in case you wondering why this was here.
 */  
class NullPointerType : PointerType
{
    this(Module mod)
    {
        super(mod, new VoidType(mod));
        dtype = DType.NullPointer;
    }
    
    override string name() { return "null"; }
}

class ArrayType : StructType
{
    private Type base;
    
    this(Module mod, Type base)
    {
        super(mod);
        this.base = base;
        dtype = DType.Array;
        addMemberVar("length", getSizeT(mod));
        addMemberVar("ptr", new PointerType(mod, base));
        declare();
    }
    
    override ArrayValue getValue(Module mod, Location location)
    {
        return new ArrayValue(mod, location, base);
    }
    
    override Type getBase()
    {
        return base;
    }
    
    override Type importToModule(Module mod)
    {
        return new ArrayType(mod, base);
    }
    
    override ast.QualifiedName getFullName()
    {
        assert(false, "tried to getFullName() on array type.");
    }
    
    override string name() { return base.name() ~ "[]"; }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Array) {
            return false;
        }
        
        return base.equals(other.getBase());
    }
}

class StaticArrayType : Type
{
    private Type base;
    size_t length;
    
    this(Module mod, Type base, size_t length)
    {
        super(mod);
        this.base = base;
        this.length = length;
        dtype = DType.StaticArray;
        mType = LLVMArrayType(base.llvmType, cast(uint) length);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return null;
    }
    
    override Type getBase()
    {
        return base;
    }
    
    override Type importToModule(Module mod)
    {
        return new StaticArrayType(mod, base, length);
    }
    
    override string name()
    {
        return format("%s[%s]", base.name(), length);
    }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.StaticArray) {
            return false;
        }
        
        auto asStaticArray = cast(StaticArrayType) other;
        return length == asStaticArray.length && base.equals(other.getBase());
    }
}

class StructType : Type
{
    ast.QualifiedName fullName;
    
    this(Module mod)
    {
        super(mod);
        dtype = DType.Struct;
    }
    
    void declare()
    {
        LLVMTypeRef[] types;
        foreach (member; members) {
            types ~= member.llvmType;
        }
        mType = LLVMStructTypeInContext(mModule.context, types.ptr, cast(uint) types.length, false);
    }
    
    override Value getValue(Module mod, Location location)
    {
        return new StructValue(mod, location, this);
    }

    void addMemberVar(string id, Type t)
    {
        memberPositions[id] = members.length;
        members ~= t;
    }
    
    void addMemberType(string id, Type t)
    {
        typeScope.redefine(id, new Store(t, Location()));
    }
    
    void addMemberFunction(string id, Function f)
    {
        memberFunctions[id] = f;    
    }
    
    mixin ImportToModule!(Type, "mod");
    
    override ast.QualifiedName getFullName()
    {
        return fullName;
    }
    
    override string name()
    { 
        return "struct " ~ extractQualifiedName(fullName);
    }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Struct) {
            return false;
        }
        
        return fullName == other.getFullName();
    }
    
    Type[] members;
    size_t[string] memberPositions;
    Function[string] memberFunctions;
}

class EnumType : Type
{
    ast.QualifiedName fullName;
    private Type base;
    
    this(Module mod, Type base)
    {
        super(mod);
        
        this.base = base;
        dtype = DType.Enum;
    }
    
    void addMember(string id, Value v)
    {
        members[id] = v;
    }
    
    mixin ImportToModule!(Type, "mod, base");
    
    override Value getValue(Module mod, Location loc)
    {
        return new EnumValue(mod, loc, this);
    }
    
    override Type getBase()
    {
        return base;
    }
    
    override ast.QualifiedName getFullName()
    {
        return fullName;
    }
    
    override string name()
    {
        return "enum " ~ extractQualifiedName(fullName);
    }
    
    override bool equals(Type other)
    {
        if (other.dtype != DType.Enum) {
            return false;
        }
        
        return fullName == other.getFullName();
    }
    
    Value[string] members;
}

/* InferredType means, as soon as we get enough information
 * to know what type this is, replace InferredType with the
 * real one.
 */
class InferredType : Type
{
    this(Module mod)
    {
        super(mod);
        dtype = DType.Inferred;
    }
    
    override Value getValue(Module mod, Location location)
    {
        throw new CompilerPanic(location, "attempted to call InferredType.getValue.");
    }
    
    override string name() { return "auto"; }
}

// This is evil.  EEEEEEEEEEEEEEEEEEEVIL.  >:D
class InferredTypeFoundException : Exception
{
    Type type;
    
    this(Type type)
    {
        super("msg");
        this.type = type;
    }
}


bool isString(Type t)
{
    return t.dtype == DType.Array && t.getBase().dtype == DType.Char;
}
