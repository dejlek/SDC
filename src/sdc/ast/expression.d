/**
 * Copyright 2010 Bernard Helyer.
 * This file is part of SDC. SDC is licensed under the GPL.
 * See LICENCE or sdc.d for more details.
 */
module sdc.ast.expression;

import sdc.token;
import sdc.ast.base;
import sdc.ast.declaration;


// AssignExpression (, Expression)?
class Expression : Node
{
    AssignExpression assignExpression;
    Expression expression;  // Optional.
}

enum AssignType
{
    None,
    Normal,
    AddAssign,
    SubAssign,
    MulAssign,
    DivAssign,
    ModAssign,
    AndAssign,
    OrAssign,
    XorAssign,
    CatAssign,
    ShiftLeftAssign,
    SignedShiftRightAssign,
    UnsignedShiftRightAssign,
    PowAssign,
}

// ConditionalExpression ((= | += | *= | etc) AssignExpression)?
class AssignExpression : Node
{
    ConditionalExpression conditionalExpression;
    AssignType assignType;
    AssignExpression assignExpression;  // Optional.
}

// OrOrExpression (? Expression : ConditionalExpression)?
class ConditionalExpression : Node
{
    OrOrExpression orOrExpression;
    Expression expression;  // Optional.
    ConditionalExpression conditionalExpression;  // Optional.
}

// (OrOrExpression ||)? AndAndExpression
class OrOrExpression : Node
{
    OrOrExpression orOrExpression;  // Optional.
    AndAndExpression andAndExpression;
}

// (AndAndExpression &&)? OrExpression
class AndAndExpression : Node
{
    AndAndExpression andAndExpression;  // Optional.
    OrExpression orExpression;
}

// (OrExpression |)? XorExpression
class OrExpression : Node
{
    OrExpression orExpression;  // Optional.
    XorExpression xorExpression;
}

// (XorExpression ^)? AndExpression
class XorExpression : Node
{
    XorExpression xorExpression;  // Optional.
    AndExpression andExpression;
}

// (AndExpression &)? CmpExpression
class AndExpression : Node
{
    AndExpression andExpression;  // Optional.
    CmpExpression cmpExpression;
}

enum Comparison
{
    None,
    Equality,
    NotEquality,
    Is,
    NotIs,
    In,
    NotIn,
    Less,
    LessEqual,
    Greater,
    GreaterEqual,
    Unordered,  // !<>=
    UnorderedEqual,  // !<>
    LessGreater,  // <>
    LessEqualGreater,  // <>=
    UnorderedLessEqual,  // !>
    UnorderedLess, // !>=
    UnorderedGreaterEqual,  // !<
    UnorderedGreater,  // !<=
}
    

// CmpExpression ((== != !is is in !in etc)  CmpExpression)?
class CmpExpression : Node
{
    ShiftExpression lhShiftExpression;
    Comparison comparison;
    ShiftExpression rhShiftExpression;  // Optional.
}

enum Shift
{
    Left,
    SignedRight,
    UnsignedRight
}

// (ShiftExpression (<<|>>|>>>))? AddExpression
class ShiftExpression : Node
{
    ShiftExpression shiftExpression;  // Optional.
    Shift shift;  // Optional.
    AddExpression addExpression;
}

enum AddOperation
{
    Add,
    Subtract,
    Concat,
}

// (AddExpression (~|+|-))? MulExpression
class AddExpression : Node
{
    AddExpression addExpression;  // Optional.
    AddOperation addOperation;  // Optional.
    MulExpression mulExpression;
}

enum MulOperation
{
    Mul,
    Div,
    Mod,
}

// (MulExpression (*|/|%))? PowExpression
class MulExpression : Node
{
    MulExpression mulExpression;  // Optional.
    MulOperation mulOperation;  // Optional.
    PowExpression powExpression;
}

// UnaryExpression (^^ PowExpression)?
class PowExpression : Node
{
    UnaryExpression unaryExpression;
    PowExpression powExpression;  // Optional.
}

enum UnaryPrefix
{
    None,
    AddressOf,  // &
    PrefixInc,  // ++
    PrefixDec,  // --
    Dereference,  // *
    UnaryMinus,  // -
    UnaryPlus,  // +
    LogicalNot,  // !
    BitwiseNot,  // ~
    Cast,  // cast (type) unaryExpr
    New,
}

class UnaryExpression : Node
{
    PostfixExpression postfixExpression;  // Optional.
    UnaryPrefix unaryPrefix;
    UnaryExpression unaryExpression;  // Optional.
    NewExpression newExpression;  // Optional.
    CastExpression castExpression;  // Optional.
}

class NewExpression : Node
{
    Type type;  // new *
    AssignExpression assignExpression;  // new blah[*]
    ArgumentList argumentList;  // new blah(*)
}

// cast ( Type ) UnaryExpression
class CastExpression : Node
{
    Type type;
    UnaryExpression unaryExpression;
}

enum PostfixType
{
    Primary,
    Dot,  // . QualifiedName  // XXX: specs say a new expression can go here: DMD disagrees.
    PostfixInc,  // ++
    PostfixDec,  // --
    Parens,  // ( ArgumentList* )
    Index,  // [ ArgumentList ]
    Slice,  // [ (AssignExpression .. AssignExpression)* ]
}

// PostfixExpression (. Identifier|++|--|(ArgumentList)|[ArgumentList]|[AssignExpression .. AssignExpression)
class PostfixExpression : Node
{
    PostfixType type;
    PostfixExpression postfixExpression;  // Optional.
    Node firstNode;  // Optional.
    Node secondNode;  // Optional.
}

class ArgumentList : Node
{
    AssignExpression[] expressions;
}

enum PrimaryType
{
    Identifier,
    GlobalIdentifier,  // . Identifier
    TemplateInstance,
    This,
    Super,
    Null,
    True,
    False,
    Dollar,
    __File__,
    __Line__,
    IntegerLiteral,
    FloatLiteral,
    CharacterLiteral,
    StringLiteral,
    ArrayLiteral,
    AssocArrayLiteral,
    FunctionLiteral,
    AssertExpression,
    MixinExpression,
    ImportExpression,
    BasicTypeDotIdentifier,
    ComplexTypeDotIdentifier,
    Typeof,
    TypeidExpression,
    IsExpression,
    ParenExpression,
    TraitsExpression,
}

class PrimaryExpression : Node
{
    PrimaryType type;
    
    /* What should be instantiated here depends 
     * on the above primary expression type.
     */
    Node node;
    Node secondNode;  // Optional.
}

// assert ( AssignExpr (, AssignExpr)? )
class AssertExpression : Node
{
    AssignExpression condition;
    AssignExpression message;  // Optional.
}

// mixin ( AssertExpr )
class MixinExpression : Node
{
    AssignExpression assignExpression;
}

// import ( AssignExpression )
class ImportExpression : Node
{
    AssignExpression assignExpression;
}

enum TypeofExpressionType
{
    Expression,
    Return,
}

class TypeofExpression : Node
{
    TypeofExpressionType type;
    Expression expression;  // Optional.
}

class TypeidExpression : Node
{
    // Mutually exclusive.
    Type type;
    Expression expression;
}

enum IsOperation
{
    SemanticCheck,  // is(T)
    ImplicitType,  // is(foo : t)
    ExplicitType,  // is(foo == t)
}

enum IsSpecialisation
{
    Type,
    Struct = TokenType.Struct,
    Union = TokenType.Union,
    Class = TokenType.Class,
    Interface = TokenType.Interface,
    Enum = TokenType.Enum,
    Function = TokenType.Function,
    Delegate = TokenType.Delegate,
    Super = TokenType.Super,
    Const = TokenType.Const,
    Immutable = TokenType.Immutable,
    Inout = TokenType.Inout,
    Shared = TokenType.Shared,
    Return = TokenType.Return,
}

class IsExpression : Node
{
    IsOperation operation;
    Type type;
    Identifier identifier;  // Optional.
    IsSpecialisation specialisation; // Optional.
    Type specialisationType; // Optional.
    // TODO: Template pararameters.
}

enum TraitsKeyword
{
    isAbstractClass,
    isArithmetic,
    isAssociativeArray,
    isFinalClass,
    isFloating,
    isIntegral,
    isScalar,
    isStaticArray,
    isUnsigned,
    isVirtualFunction,
    isAbstractFunction,
    isFinalFunction,
    isStaticFunction,
    isRef,
    isOut,
    isLazy,
    hasMember,
    identifier,
    getMember,
    getOverloads,
    getVirtualFunctions,
    classInstanceSize,
    allMembers,
    derivedMembers,
    isSame,
    compiles,
}


class TraitsExpression : Node
{
    TraitsKeyword keyword;
    TraitsArguments traitsArguments;
}

class TraitsArguments : Node
{
    TraitsArgument traitsArgument;
    TraitsArguments traitsArguments;  // Optional.
}

class TraitsArgument : Node
{
    // Mutually exclusive.
    Type type;
    AssignExpression assignExpression;
}
