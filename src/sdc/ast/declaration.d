/**
 * Copyright 2010 Bernard Helyer.
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */
module sdc.ast.declaration;

import sdc.token;
import sdc.ast.base;
import sdc.ast.expression;
import sdc.ast.statement;
import sdc.ast.attribute;
import sdc.ast.sdctemplate;


enum DeclarationType
{
    Variable,
    Function,
    FunctionTemplate,
    Alias,
    AliasThis,
    Mixin,
}

class Declaration : Node
{
    DeclarationType type;
    Node node;
}

class MixinDeclaration : Node
{
    ConditionalExpression expression;
    Declaration declarationCache;
}

class VariableDeclaration : Node
{
    bool isAlias;
    bool isExtern;
    Type type;
    Declarator[] declarators;
}

class Declarator : Node
{
    Identifier name;
    Initialiser initialiser;  // Optional.
}

class ParameterList : Node
{
    Parameter[] parameters;
    bool varargs = false;
}
    
class FunctionDeclaration : Node
{
    Type returnType;
    QualifiedName name;
    ParameterList parameterList;
    FunctionBody functionBody;  // Optional.
    FunctionBody inContract; // Optional.
    FunctionBody outContract; // Optional.
}

class FunctionBody : Node
{
    BlockStatement statement;
    // TODO
}

enum TypeType
{
    Primitive,
    Inferred,
    UserDefined,
    Typeof,
    FunctionPointer,
    Delegate,
    ConstType,  // const(Type)
    ImmutableType,  // immutable(Type)
    SharedType,  // shared(Type)
    InoutType,  // inout(Type)
}

enum StorageType
{
    Abstract = TokenType.Abstract,
    Auto = TokenType.Auto,
    Const = TokenType.Const,
    Deprecated = TokenType.Deprecated,
    Extern = TokenType.Extern,
    Final = TokenType.Final,
    Immutable = TokenType.Immutable,
    Inout = TokenType.Inout,
    Shared = TokenType.Shared,
    Nothrow = TokenType.Nothrow,
    Override = TokenType.Override,
    Pure = TokenType.Pure,
    Scope = TokenType.Scope,
    Static = TokenType.Static,
    Synchronized = TokenType.Synchronized,
}
immutable STORAGE_TYPES = [
TokenType.Abstract, TokenType.Auto, TokenType.Const,
TokenType.Deprecated, TokenType.Extern, TokenType.Final,
TokenType.Immutable, TokenType.Inout, TokenType.Shared,
TokenType.Nothrow, TokenType.Override, TokenType.Pure,
TokenType.Scope, TokenType.Static, TokenType.Synchronized
];

immutable PAREN_TYPES = [
TokenType.Const, TokenType.Immutable, TokenType.Shared, TokenType.Inout,
TokenType.Function,
];


class Type : Node
{
    TypeType type;
    Node node;
    StorageType[] storageTypes;
    TypeSuffix[] suffixes;
    bool ctor = false;
    bool dtor = false;
}

enum TypeSuffixType
{
    Pointer,
    Array,
}

class TypeSuffix : Node
{
    TypeSuffixType type;
    Node node;  // Optional.
}

enum PrimitiveTypeType
{
    Bool = TokenType.Bool,
    Byte = TokenType.Byte,
    Ubyte = TokenType.Ubyte,
    Short = TokenType.Short,
    Ushort = TokenType.Ushort,
    Int = TokenType.Int,
    Uint = TokenType.Uint,
    Long = TokenType.Long,
    Ulong = TokenType.Ulong,
    Cent = TokenType.Cent,
    Ucent = TokenType.Ucent,
    Char = TokenType.Char,
    Wchar = TokenType.Wchar,
    Dchar = TokenType.Dchar,
    Float = TokenType.Float,
    Double = TokenType.Double,
    Real = TokenType.Real,
    Ifloat = TokenType.Ifloat,
    Idouble = TokenType.Idouble, 
    Ireal = TokenType.Ireal,
    Cfloat = TokenType.Cfloat,
    Cdouble = TokenType.Cdouble,
    Creal = TokenType.Creal,
    Void = TokenType.Void,
}

class PrimitiveType : Node
{
    PrimitiveTypeType type;
}

class UserDefinedType : Node
{
    IdentifierOrTemplateInstance[] segments;
}

class IdentifierOrTemplateInstance : Node
{
    bool isIdentifier;
    Node node;
}

enum TypeofTypeType
{
    Return,
    This,
    Super,
    Expression
}

class TypeofType : Node
{
    TypeofTypeType type;
    Expression expression;  // Optional.
    QualifiedName qualifiedName;  // Optional.
}

class FunctionPointerType : Node
{
    Type returnType;
    ParameterList parameters;
}

class DelegateType : Node
{
    Type returnType;
    ParameterList parameters;
}

enum ParameterAttribute
{
    None,
    In,
    Out,
    Ref,
    Lazy,
}

class Parameter : Node
{
    ParameterAttribute attribute;
    Type type;
    Identifier identifier;  // Optional.
    bool defaultArgumentFile = false;  // Optional.
    bool defaultArgumentLine = false;  // Optional.
    ConditionalExpression defaultArgument;  // Optional.
}

enum InitialiserType
{
    Void,
    AssignExpression
}

class Initialiser : Node
{
    InitialiserType type;
    Node node; // Optional.
}

