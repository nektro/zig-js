//! A streaming parser for ECMAScript.
//!
//! grammar rules current as of Draft ECMA-262 / November 3, 2023
//! https://tc39.es/ecma262/

const std = @import("std");
const string = []const u8;
const Parser = @import("./Parser.zig");
const extras = @import("extras");

pub fn do(alloc: std.mem.Allocator, path: string, inreader: anytype, isModule: bool) !void {
    //
    _ = path;

    var counter = std.io.countingReader(inreader);
    const anyreader = extras.AnyReader.from(counter.reader());
    var p = Parser.init(alloc, anyreader);
    defer p.deinit();
    defer p.extras.deinit(alloc);
    defer p.string_bytes.deinit(alloc);
    defer p.strings_map.deinit(alloc);

    _ = try p.addStr(alloc, "");

    if (isModule) {
        return parseModule(alloc, &p);
    }
    return parseScript(alloc, &p);
}

/// Script : ScriptBody?
fn parseScript(alloc: std.mem.Allocator, p: *Parser) !void {
    //
    _ = alloc;
    _ = p;
    _ = &parseScriptBody;
    return error.TODO;
}

/// ScriptBody : StatementList[~Yield, ~Await, ~Return]
fn parseScriptBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseStatementList;
    return error.TODO;
}

/// StatementList[Yield, Await, Return] : StatementListItem[?Yield, ?Await, ?Return]
/// StatementList[Yield, Await, Return] : StatementList[?Yield, ?Await, ?Return] StatementListItem[?Yield, ?Await, ?Return]
fn parseStatementList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseStatementListItem;
    return error.TODO;
}

/// StatementListItem[Yield, Await, Return] : Statement[?Yield, ?Await, ?Return]
/// StatementListItem[Yield, Await, Return] : Declaration[?Yield, ?Await]
fn parseStatementListItem(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseStatement;
    _ = &parseDeclaration;
    return error.TODO;
}

/// Statement[Yield, Await, Return] : BlockStatement[?Yield, ?Await, ?Return]
/// Statement[Yield, Await, Return] : VariableStatement[?Yield, ?Await]
/// Statement[Yield, Await, Return] : EmptyStatement
/// Statement[Yield, Await, Return] : ExpressionStatement[?Yield, ?Await]
/// Statement[Yield, Await, Return] : IfStatement[?Yield, ?Await, ?Return]
/// Statement[Yield, Await, Return] : BreakableStatement[?Yield, ?Await, ?Return]
/// Statement[Yield, Await, Return] : ContinueStatement[?Yield, ?Await]
/// Statement[Yield, Await, Return] : BreakStatement[?Yield, ?Await]
/// Statement[Yield, Await, Return] : [+Return] ReturnStatement[?Yield, ?Await]
/// Statement[Yield, Await, Return] : WithStatement[?Yield, ?Await, ?Return]
/// Statement[Yield, Await, Return] : LabelledStatement[?Yield, ?Await, ?Return]
/// Statement[Yield, Await, Return] : ThrowStatement[?Yield, ?Await]
/// Statement[Yield, Await, Return] : TryStatement[?Yield, ?Await, ?Return]
/// Statement[Yield, Await, Return] : DebuggerStatement
fn parseStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseBlockStatement;
    _ = &parseVariableStatement;
    _ = &parseEmptyStatement;
    _ = &parseExpressionStatement;
    _ = &parseIfStatement;
    _ = &parseBreakableStatement;
    _ = &parseContinueStatement;
    _ = &parseBreakStatement;
    _ = &parseReturnStatement;
    _ = &parseLabelledStatement;
    _ = &parseThrowStatement;
    _ = &parseTryStatement;
    _ = &parseDebuggerStatement;
    return error.TODO;
}

/// Declaration[Yield, Await] : HoistableDeclaration[?Yield, ?Await, ~Default]
/// Declaration[Yield, Await] : ClassDeclaration[?Yield, ?Await, ~Default]
/// Declaration[Yield, Await] : LexicalDeclaration[+In, ?Yield, ?Await]
fn parseDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseHoistableDeclaration;
    _ = &parseClassDeclaration;
    _ = &parseLexicalDeclaration;
    return error.TODO;
}

/// BlockStatement[Yield, Await, Return] : Block[?Yield, ?Await, ?Return]
fn parseBlockStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseBlock;
    return error.TODO;
}

/// VariableStatement[Yield, Await] : var VariableDeclarationList[+In, ?Yield, ?Await] ;
fn parseVariableStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseVariableDeclarationList;
    return error.TODO;
}

/// EmptyStatement : ;
fn parseEmptyStatement(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// ExpressionStatement[Yield, Await] : [lookahead ∉ { {, function, async [no LineTerminator here] function, class, let [ }] Expression[+In, ?Yield, ?Await] ;
fn parseExpressionStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseExpression;
    return error.TODO;
}

/// IfStatement[Yield, Await, Return] : if ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return] else Statement[?Yield, ?Await, ?Return]
/// IfStatement[Yield, Await, Return] : if ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return] [lookahead ≠ else]
fn parseIfStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseExpression;
    _ = &parseStatement;
    return error.TODO;
}

/// BreakableStatement[Yield, Await, Return] : IterationStatement[?Yield, ?Await, ?Return]
/// BreakableStatement[Yield, Await, Return] : SwitchStatement[?Yield, ?Await, ?Return]
fn parseBreakableStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseIterationStatement;
    _ = &parseSwitchStatement;
    return error.TODO;
}

/// ContinueStatement[Yield, Await] : continue ;
/// ContinueStatement[Yield, Await] : continue [no LineTerminator here] LabelIdentifier[?Yield, ?Await] ;
fn parseContinueStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseLabelIdentifier;
    return error.TODO;
}

/// BreakStatement[Yield, Await] : break ;
/// BreakStatement[Yield, Await] : break [no LineTerminator here] LabelIdentifier[?Yield, ?Await] ;
fn parseBreakStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseLabelIdentifier;
    return error.TODO;
}

/// ReturnStatement[Yield, Await] : return ;
/// ReturnStatement[Yield, Await] : return [no LineTerminator here] Expression[+In, ?Yield, ?Await] ;
fn parseReturnStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseExpression;
    return error.TODO;
}

/// LabelledStatement[Yield, Await, Return] : LabelIdentifier[?Yield, ?Await] : LabelledItem[?Yield, ?Await, ?Return]
fn parseLabelledStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseLabelIdentifier;
    _ = &parseLabelledItem;
    return error.TODO;
}

/// ThrowStatement[Yield, Await] : throw [no LineTerminator here] Expression[+In, ?Yield, ?Await] ;
fn parseThrowStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseExpression;
    return error.TODO;
}

/// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Catch[?Yield, ?Await, ?Return]
/// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Finally[?Yield, ?Await, ?Return]
/// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Catch[?Yield, ?Await, ?Return] Finally[?Yield, ?Await, ?Return]
fn parseTryStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseBlock;
    _ = &parseCatch;
    _ = &parseFinally;
    return error.TODO;
}

/// DebuggerStatement : debugger ;
fn parseDebuggerStatement(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// HoistableDeclaration[Yield, Await, Default] : FunctionDeclaration[?Yield, ?Await, ?Default]
/// HoistableDeclaration[Yield, Await, Default] : GeneratorDeclaration[?Yield, ?Await, ?Default]
/// HoistableDeclaration[Yield, Await, Default] : AsyncFunctionDeclaration[?Yield, ?Await, ?Default]
/// HoistableDeclaration[Yield, Await, Default] : AsyncGeneratorDeclaration[?Yield, ?Await, ?Default]
fn parseHoistableDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Default: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Default;
    _ = &parseFunctionDeclaration;
    _ = &parseGeneratorDeclaration;
    _ = &parseAsyncFunctionDeclaration;
    _ = &parseAsyncGeneratorDeclaration;
    return error.TODO;
}

/// ClassDeclaration[Yield, Await, Default] : class BindingIdentifier[?Yield, ?Await] ClassTail[?Yield, ?Await]
/// ClassDeclaration[Yield, Await, Default] : [+Default] class ClassTail[?Yield, ?Await]
fn parseClassDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Default: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Default;
    _ = &parseBindingIdentifier;
    _ = &parseClassTail;
    return error.TODO;
}

/// LexicalDeclaration[In, Yield, Await] : LetOrConst BindingList[?In, ?Yield, ?Await] ;
fn parseLexicalDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseLetOrConst;
    _ = &parseBindingList;
    return error.TODO;
}

/// Block[Yield, Await, Return] : { StatementList[?Yield, ?Await, ?Return]? }
fn parseBlock(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    return error.TODO;
}

/// VariableDeclarationList[In, Yield, Await] : VariableDeclaration[?In, ?Yield, ?Await]
/// VariableDeclarationList[In, Yield, Await] : VariableDeclarationList[?In, ?Yield, ?Await] , VariableDeclaration[?In, ?Yield, ?Await]
fn parseVariableDeclarationList(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseVariableDeclaration;
    return error.TODO;
}

/// Expression[In, Yield, Await] : AssignmentExpression[?In, ?Yield, ?Await]
/// Expression[In, Yield, Await] : Expression[?In, ?Yield, ?Await] , AssignmentExpression[?In, ?Yield, ?Await]
fn parseExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// IterationStatement[Yield, Await, Return] : DoWhileStatement[?Yield, ?Await, ?Return]
/// IterationStatement[Yield, Await, Return] : WhileStatement[?Yield, ?Await, ?Return]
/// IterationStatement[Yield, Await, Return] : ForStatement[?Yield, ?Await, ?Return]
/// IterationStatement[Yield, Await, Return] : ForInOfStatement[?Yield, ?Await, ?Return]
fn parseIterationStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseDoWhileStatement;
    _ = &parseWhileStatement;
    _ = &parseForStatement;
    _ = &parseForInOfStatement;
    return error.TODO;
}

/// SwitchStatement[Yield, Await, Return] : switch ( Expression[+In, ?Yield, ?Await] ) CaseBlock[?Yield, ?Await, ?Return]
fn parseSwitchStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseExpression;
    _ = &parseCaseBlock;
    return error.TODO;
}

/// LabelIdentifier[Yield, Await] : Identifier
/// LabelIdentifier[Yield, Await] : [~Yield] yield
/// LabelIdentifier[Yield, Await] : [~Await] await
fn parseLabelIdentifier(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseIdentifier;
    return error.TODO;
}

/// LabelledItem[Yield, Await, Return] : Statement[?Yield, ?Await, ?Return]
/// LabelledItem[Yield, Await, Return] : FunctionDeclaration[?Yield, ?Await, ~Default]
fn parseLabelledItem(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseStatement;
    _ = &parseFunctionDeclaration;
    return error.TODO;
}

/// Catch[Yield, Await, Return] : catch ( CatchParameter[?Yield, ?Await] ) Block[?Yield, ?Await, ?Return]
/// Catch[Yield, Await, Return] : catch Block[?Yield, ?Await, ?Return]
fn parseCatch(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseCatchParameter;
    _ = &parseBlock;
    return error.TODO;
}

/// Finally[Yield, Await, Return] : finally Block[?Yield, ?Await, ?Return]
fn parseFinally(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseBlock;
    return error.TODO;
}

/// FunctionDeclaration[Yield, Await, Default] : function BindingIdentifier[?Yield, ?Await] ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
/// FunctionDeclaration[Yield, Await, Default] : [+Default] function ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
fn parseFunctionDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Default: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Default;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseFunctionBody;
    return error.TODO;
}

/// GeneratorDeclaration[Yield, Await, Default] : function * BindingIdentifier[?Yield, ?Await] ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
/// GeneratorDeclaration[Yield, Await, Default] : [+Default] function * ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Default: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Default;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseGeneratorBody;
    return error.TODO;
}

/// AsyncFunctionDeclaration[Yield, Await, Default] : async [no LineTerminator here] function BindingIdentifier[?Yield, ?Await] ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
/// AsyncFunctionDeclaration[Yield, Await, Default] : [+Default] async [no LineTerminator here] function ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncFunctionDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Default: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Default;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncFunctionBody;
    return error.TODO;
}

/// AsyncGeneratorDeclaration[Yield, Await, Default] : async [no LineTerminator here] function * BindingIdentifier[?Yield, ?Await] ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
/// AsyncGeneratorDeclaration[Yield, Await, Default] : [+Default] async [no LineTerminator here] function * ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Default: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Default;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncGeneratorBody;
    return error.TODO;
}

/// BindingIdentifier[Yield, Await] : Identifier
/// BindingIdentifier[Yield, Await] : yield
/// BindingIdentifier[Yield, Await] : await
fn parseBindingIdentifier(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseIdentifier;
    return error.TODO;
}

/// ClassTail[Yield, Await] : ClassHeritage[?Yield, ?Await]? { ClassBody[?Yield, ?Await]? }
fn parseClassTail(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassHeritage;
    _ = &parseClassBody;
    return error.TODO;
}

/// LetOrConst : let
/// LetOrConst : const
fn parseLetOrConst(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// BindingList[In, Yield, Await] : LexicalBinding[?In, ?Yield, ?Await]
/// BindingList[In, Yield, Await] : BindingList[?In, ?Yield, ?Await] , LexicalBinding[?In, ?Yield, ?Await]
fn parseBindingList(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseLexicalBinding;
    _ = &parseBindingList;
    return error.TODO;
}

/// VariableDeclaration[In, Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]?
/// VariableDeclaration[In, Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]
fn parseVariableDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    _ = &parseInitializer;
    return error.TODO;
}

/// AssignmentExpression[In, Yield, Await] : ConditionalExpression[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : [+Yield] YieldExpression[?In, ?Await]
/// AssignmentExpression[In, Yield, Await] : ArrowFunction[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : AsyncArrowFunction[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] = AssignmentExpression[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] AssignmentOperator AssignmentExpression[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] &&= AssignmentExpression[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] ||= AssignmentExpression[?In, ?Yield, ?Await]
/// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] ??= AssignmentExpression[?In, ?Yield, ?Await]
fn parseAssignmentExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseConditionalExpression;
    _ = &parseYieldExpression;
    _ = &parseArrowFunction;
    _ = &parseAsyncArrowFunction;
    _ = &parseLeftHandSideExpression;
    _ = &parseAssignmentExpression;
    _ = &parseAssignmentOperator;
    return error.TODO;
}

/// DoWhileStatement[Yield, Await, Return] : do Statement[?Yield, ?Await, ?Return] while ( Expression[+In, ?Yield, ?Await] ) ;
fn parseDoWhileStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseStatement;
    _ = &parseExpression;
    return error.TODO;
}

/// WhileStatement[Yield, Await, Return] : while ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
fn parseWhileStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseExpression;
    _ = &parseStatement;
    return error.TODO;
}

/// ForStatement[Yield, Await, Return] : for ( [lookahead ≠ let [] Expression[~In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
/// ForStatement[Yield, Await, Return] : for ( var VariableDeclarationList[~In, ?Yield, ?Await] ; Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
/// ForStatement[Yield, Await, Return] : for ( LexicalDeclaration[~In, ?Yield, ?Await] Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
fn parseForStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseExpression;
    _ = &parseStatement;
    _ = &parseVariableDeclarationList;
    _ = &parseLexicalDeclaration;
    return error.TODO;
}

/// ForInOfStatement[Yield, Await, Return] : for ( [lookahead ≠ let [] LeftHandSideExpression[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : for ( var ForBinding[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : for ( ForDeclaration[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : for ( [lookahead ∉ { let, async of }] LeftHandSideExpression[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : for ( var ForBinding[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : for ( ForDeclaration[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : [+Await] for await ( [lookahead ≠ let] LeftHandSideExpression[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : [+Await] for await ( var ForBinding[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
/// ForInOfStatement[Yield, Await, Return] : [+Await] for await ( ForDeclaration[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
fn parseForInOfStatement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseLeftHandSideExpression;
    _ = &parseExpression;
    _ = &parseStatement;
    _ = &parseForBinding;
    _ = &parseForDeclaration;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// CaseBlock[Yield, Await, Return] : { CaseClauses[?Yield, ?Await, ?Return]? }
/// CaseBlock[Yield, Await, Return] : { CaseClauses[?Yield, ?Await, ?Return]? DefaultClause[?Yield, ?Await, ?Return] CaseClauses[?Yield, ?Await, ?Return]? }
fn parseCaseBlock(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseCaseClauses;
    _ = &parseDefaultClause;
    return error.TODO;
}

/// Identifier : IdentifierName but not ReservedWord
fn parseIdentifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierName;
    _ = &parseReservedWord;
    return error.TODO;
}

/// CatchParameter[Yield, Await] : BindingIdentifier[?Yield, ?Await]
/// CatchParameter[Yield, Await] : BindingPattern[?Yield, ?Await]
fn parseCatchParameter(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    return error.TODO;
}

/// FormalParameters[Yield, Await] : [empty]
/// FormalParameters[Yield, Await] : FunctionRestParameter[?Yield, ?Await]
/// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await]
/// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await] ,
/// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await] , FunctionRestParameter[?Yield, ?Await]
fn parseFormalParameters(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseFunctionRestParameter;
    _ = &parseFormalParameterList;
    return error.TODO;
}

/// FunctionBody[Yield, Await] : FunctionStatementList[?Yield, ?Await]
fn parseFunctionBody(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseFunctionStatementList;
    return error.TODO;
}

/// GeneratorBody : FunctionBody[+Yield, ~Await]
fn parseGeneratorBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseFunctionBody;
    return error.TODO;
}

/// AsyncFunctionBody : FunctionBody[~Yield, +Await]
fn parseAsyncFunctionBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseFunctionBody;
    return error.TODO;
}

/// AsyncGeneratorBody : FunctionBody[+Yield, +Await]
fn parseAsyncGeneratorBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseFunctionBody;
    return error.TODO;
}

/// ClassHeritage[Yield, Await] : extends LeftHandSideExpression[?Yield, ?Await]
fn parseClassHeritage(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseLeftHandSideExpression;
    return error.TODO;
}

/// ClassBody[Yield, Await] : ClassElementList[?Yield, ?Await]
fn parseClassBody(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElementList;
    return error.TODO;
}

/// LexicalBinding[In, Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]?
/// LexicalBinding[In, Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]
fn parseLexicalBinding(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    _ = &parseInitializer;
    return error.TODO;
}

/// BindingPattern[Yield, Await] : ObjectBindingPattern[?Yield, ?Await]
/// BindingPattern[Yield, Await] : ArrayBindingPattern[?Yield, ?Await]
fn parseBindingPattern(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseObjectBindingPattern;
    _ = &parseArrayBindingPattern;
    return error.TODO;
}

/// Initializer[In, Yield, Await] : = AssignmentExpression[?In, ?Yield, ?Await]
fn parseInitializer(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// ConditionalExpression[In, Yield, Await] : ShortCircuitExpression[?In, ?Yield, ?Await]
/// ConditionalExpression[In, Yield, Await] : ShortCircuitExpression[?In, ?Yield, ?Await] ? AssignmentExpression[+In, ?Yield, ?Await] : AssignmentExpression[?In, ?Yield, ?Await]
fn parseConditionalExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseShortCircuitExpression;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// YieldExpression[In, Await] : yield
/// YieldExpression[In, Await] : yield [no LineTerminator here] AssignmentExpression[?In, +Yield, ?Await]
/// YieldExpression[In, Await] : yield [no LineTerminator here] * AssignmentExpression[?In, +Yield, ?Await]
fn parseYieldExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// ArrowFunction[In, Yield, Await] : ArrowParameters[?Yield, ?Await] [no LineTerminator here] => ConciseBody[?In]
fn parseArrowFunction(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseArrowParameters;
    _ = &parseConciseBody;
    return error.TODO;
}

/// AsyncArrowFunction[In, Yield, Await] : async [no LineTerminator here] AsyncArrowBindingIdentifier[?Yield] [no LineTerminator here] => AsyncConciseBody[?In]
/// AsyncArrowFunction[In, Yield, Await] : CoverCallExpressionAndAsyncArrowHead[?Yield, ?Await] [no LineTerminator here] => AsyncConciseBody[?In]
fn parseAsyncArrowFunction(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseAsyncArrowBindingIdentifier;
    _ = &parseCoverCallExpressionAndAsyncArrowHead;
    _ = &parseAsyncConciseBody;
    return error.TODO;
}

/// LeftHandSideExpression[Yield, Await] : NewExpression[?Yield, ?Await]
/// LeftHandSideExpression[Yield, Await] : CallExpression[?Yield, ?Await]
/// LeftHandSideExpression[Yield, Await] : OptionalExpression[?Yield, ?Await]
fn parseLeftHandSideExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseNewExpression;
    _ = &parseCallExpression;
    _ = &parseOptionalExpression;
    return error.TODO;
}

///  AssignmentOperator : one of
/// *= /= %= += -= <<= >>= >>>= &= ^= |= **=
fn parseAssignmentOperator(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// ForBinding[Yield, Await] : BindingIdentifier[?Yield, ?Await]
/// ForBinding[Yield, Await] : BindingPattern[?Yield, ?Await]
fn parseForBinding(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    return error.TODO;
}

/// ForDeclaration[Yield, Await] : LetOrConst ForBinding[?Yield, ?Await]
fn parseForDeclaration(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseLetOrConst;
    _ = &parseForBinding;
    return error.TODO;
}

/// CaseClauses[Yield, Await, Return] : CaseClause[?Yield, ?Await, ?Return]
/// CaseClauses[Yield, Await, Return] : CaseClauses[?Yield, ?Await, ?Return] CaseClause[?Yield, ?Await, ?Return]
fn parseCaseClauses(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseCaseClause;
    return error.TODO;
}

/// DefaultClause[Yield, Await, Return] : default : StatementList[?Yield, ?Await, ?Return]?
fn parseDefaultClause(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseStatementList;
    return error.TODO;
}

/// IdentifierName :: IdentifierStart
/// IdentifierName :: IdentifierName IdentifierPart
fn parseIdentifierName(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierStart;
    _ = &parseIdentifierName;
    _ = &parseIdentifierPart;
    return error.TODO;
}

///  ReservedWord :: one of
/// await break case catch class const continue debugger default delete do else enum export extends false finally for function if import in instanceof new null return super switch this throw true try typeof var void while with yield
fn parseReservedWord(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// FunctionRestParameter[Yield, Await] : BindingRestElement[?Yield, ?Await]
fn parseFunctionRestParameter(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingRestElement;
    return error.TODO;
}

/// FormalParameterList[Yield, Await] : FormalParameter[?Yield, ?Await]
/// FormalParameterList[Yield, Await] : FormalParameterList[?Yield, ?Await] , FormalParameter[?Yield, ?Await]
fn parseFormalParameterList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseFormalParameter;
    return error.TODO;
}

/// FunctionStatementList[Yield, Await] : StatementList[?Yield, ?Await, +Return]?
fn parseFunctionStatementList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseStatementList;
    return error.TODO;
}

/// ClassElementList[Yield, Await] : ClassElement[?Yield, ?Await]
/// ClassElementList[Yield, Await] : ClassElementList[?Yield, ?Await] ClassElement[?Yield, ?Await]
fn parseClassElementList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElement;
    return error.TODO;
}

/// ObjectBindingPattern[Yield, Await] : { }
/// ObjectBindingPattern[Yield, Await] : { BindingRestProperty[?Yield, ?Await] }
/// ObjectBindingPattern[Yield, Await] : { BindingPropertyList[?Yield, ?Await] }
/// ObjectBindingPattern[Yield, Await] : { BindingPropertyList[?Yield, ?Await] , BindingRestProperty[?Yield, ?Await]? }
fn parseObjectBindingPattern(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingRestProperty;
    _ = &parseBindingPropertyList;
    return error.TODO;
}

/// ArrayBindingPattern[Yield, Await] : [ Elision? BindingRestElement[?Yield, ?Await]? ]
/// ArrayBindingPattern[Yield, Await] : [ BindingElementList[?Yield, ?Await] ]
/// ArrayBindingPattern[Yield, Await] : [ BindingElementList[?Yield, ?Await] , Elision? BindingRestElement[?Yield, ?Await]? ]
fn parseArrayBindingPattern(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseElision;
    _ = &parseBindingRestElement;
    _ = &parseBindingElementList;
    return error.TODO;
}

/// ShortCircuitExpression[In, Yield, Await] : LogicalORExpression[?In, ?Yield, ?Await]
/// ShortCircuitExpression[In, Yield, Await] : CoalesceExpression[?In, ?Yield, ?Await]
fn parseShortCircuitExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseLogicalORExpression;
    _ = &parseCoalesceExpression;
    return error.TODO;
}

/// ArrowParameters[Yield, Await] : BindingIdentifier[?Yield, ?Await]
/// ArrowParameters[Yield, Await] : CoverParenthesizedExpressionAndArrowParameterList[?Yield, ?Await]
fn parseArrowParameters(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseCoverParenthesizedExpressionAndArrowParameterList;
    return error.TODO;
}

/// ConciseBody[In] : [lookahead ≠ {] ExpressionBody[?In, ~Await]
/// ConciseBody[In] : { FunctionBody[~Yield, ~Await] }
fn parseConciseBody(alloc: std.mem.Allocator, p: *Parser, comptime In: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = &parseExpressionBody;
    _ = &parseFunctionBody;
    return error.TODO;
}

/// AsyncArrowBindingIdentifier[Yield] : BindingIdentifier[?Yield, +Await]
fn parseAsyncArrowBindingIdentifier(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = &parseBindingIdentifier;
    return error.TODO;
}

/// CoverCallExpressionAndAsyncArrowHead[Yield, Await] : MemberExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
fn parseCoverCallExpressionAndAsyncArrowHead(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseMemberExpression;
    _ = &parseArguments;
    return error.TODO;
}

/// AsyncConciseBody[In] : [lookahead ≠ {] ExpressionBody[?In, +Await]
/// AsyncConciseBody[In] : { AsyncFunctionBody }
fn parseAsyncConciseBody(alloc: std.mem.Allocator, p: *Parser, comptime In: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = &parseExpressionBody;
    _ = &parseAsyncFunctionBody;
    return error.TODO;
}

/// NewExpression[Yield, Await] : MemberExpression[?Yield, ?Await]
/// NewExpression[Yield, Await] : new NewExpression[?Yield, ?Await]
fn parseNewExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseMemberExpression;
    return error.TODO;
}

/// CallExpression[Yield, Await] : CoverCallExpressionAndAsyncArrowHead[?Yield, ?Await]
/// CallExpression[Yield, Await] : SuperCall[?Yield, ?Await]
/// CallExpression[Yield, Await] : ImportCall[?Yield, ?Await]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . IdentifierName
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . PrivateIdentifier
fn parseCallExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseCoverCallExpressionAndAsyncArrowHead;
    _ = &parseSuperCall;
    _ = &parseImportCall;
    _ = &parseArguments;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parsePrivateIdentifier;
    return error.TODO;
}

/// OptionalExpression[Yield, Await] : MemberExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
/// OptionalExpression[Yield, Await] : CallExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
/// OptionalExpression[Yield, Await] : OptionalExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
fn parseOptionalExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseMemberExpression;
    _ = &parseCallExpression;
    _ = &parseOptionalChain;
    return error.TODO;
}

/// CaseClause[Yield, Await, Return] : case Expression[+In, ?Yield, ?Await] : StatementList[?Yield, ?Await, ?Return]?
fn parseCaseClause(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Return: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Return;
    _ = &parseExpression;
    _ = &parseStatementList;
    return error.TODO;
}

/// IdentifierStart :: IdentifierStartChar
/// IdentifierStart :: \ UnicodeEscapeSequence
fn parseIdentifierStart(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierStartChar;
    _ = &parseUnicodeEscapeSequence;
    return error.TODO;
}

/// IdentifierPart :: IdentifierPartChar
/// IdentifierPart :: \ UnicodeEscapeSequence
fn parseIdentifierPart(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierPartChar;
    _ = &parseUnicodeEscapeSequence;
    return error.TODO;
}

/// BindingRestElement[Yield, Await] : ... BindingIdentifier[?Yield, ?Await]
/// BindingRestElement[Yield, Await] : ... BindingPattern[?Yield, ?Await]
fn parseBindingRestElement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    return error.TODO;
}

/// FormalParameter[Yield, Await] : BindingElement[?Yield, ?Await]
fn parseFormalParameter(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingElement;
    return error.TODO;
}

/// ClassElement[Yield, Await] : MethodDefinition[?Yield, ?Await]
/// ClassElement[Yield, Await] : static MethodDefinition[?Yield, ?Await]
/// ClassElement[Yield, Await] : FieldDefinition[?Yield, ?Await] ;
/// ClassElement[Yield, Await] : static FieldDefinition[?Yield, ?Await] ;
/// ClassElement[Yield, Await] : ClassStaticBlock
/// ClassElement[Yield, Await] : ;
fn parseClassElement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseMethodDefinition;
    _ = &parseFieldDefinition;
    _ = &parseClassStaticBlock;
    return error.TODO;
}

/// BindingRestProperty[Yield, Await] : ... BindingIdentifier[?Yield, ?Await]
fn parseBindingRestProperty(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    return error.TODO;
}

/// BindingPropertyList[Yield, Await] : BindingProperty[?Yield, ?Await]
/// BindingPropertyList[Yield, Await] : BindingPropertyList[?Yield, ?Await] , BindingProperty[?Yield, ?Await]
fn parseBindingPropertyList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingProperty;
    return error.TODO;
}

/// Elision : ,
/// Elision : Elision ,
fn parseElision(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// BindingElementList[Yield, Await] : BindingElisionElement[?Yield, ?Await]
/// BindingElementList[Yield, Await] : BindingElementList[?Yield, ?Await] , BindingElisionElement[?Yield, ?Await]
fn parseBindingElementList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingElisionElement;
    return error.TODO;
}

/// LogicalORExpression[In, Yield, Await] : LogicalANDExpression[?In, ?Yield, ?Await]
/// LogicalORExpression[In, Yield, Await] : LogicalORExpression[?In, ?Yield, ?Await] || LogicalANDExpression[?In, ?Yield, ?Await]
fn parseLogicalORExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseLogicalANDExpression;
    return error.TODO;
}

/// CoalesceExpression[In, Yield, Await] : CoalesceExpressionHead[?In, ?Yield, ?Await] ?? BitwiseORExpression[?In, ?Yield, ?Await]
fn parseCoalesceExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseCoalesceExpressionHead;
    _ = &parseBitwiseORExpression;
    return error.TODO;
}

/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( ... BindingIdentifier[?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( ... BindingPattern[?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , ... BindingIdentifier[?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , ... BindingPattern[?Yield, ?Await] )
fn parseCoverParenthesizedExpressionAndArrowParameterList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseExpression;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    return error.TODO;
}

/// ExpressionBody[In, Await] : AssignmentExpression[?In, ~Yield, ?Await]
fn parseExpressionBody(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// MemberExpression[Yield, Await] : PrimaryExpression[?Yield, ?Await]
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . IdentifierName
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
/// MemberExpression[Yield, Await] : SuperProperty[?Yield, ?Await]
/// MemberExpression[Yield, Await] : MetaProperty
/// MemberExpression[Yield, Await] : new MemberExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . PrivateIdentifier
fn parseMemberExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parsePrimaryExpression;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parseSuperProperty;
    _ = &parseMetaProperty;
    _ = &parseArguments;
    _ = &parsePrivateIdentifier;
    return error.TODO;
}

/// Arguments[Yield, Await] : ( )
/// Arguments[Yield, Await] : ( ArgumentList[?Yield, ?Await] )
/// Arguments[Yield, Await] : ( ArgumentList[?Yield, ?Await] , )
fn parseArguments(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseArgumentList;
    return error.TODO;
}

/// SuperCall[Yield, Await] : super Arguments[?Yield, ?Await]
fn parseSuperCall(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseArguments;
    return error.TODO;
}

/// ImportCall[Yield, Await] : import ( AssignmentExpression[+In, ?Yield, ?Await] )
fn parseImportCall(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// TemplateLiteral[Yield, Await, Tagged] : NoSubstitutionTemplate
/// TemplateLiteral[Yield, Await, Tagged] : SubstitutionTemplate[?Yield, ?Await, ?Tagged]
fn parseTemplateLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Tagged: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Tagged;
    _ = &parseNoSubstitutionTemplate;
    _ = &parseSubstitutionTemplate;
    return error.TODO;
}

/// PrivateIdentifier :: # IdentifierName
fn parsePrivateIdentifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierName;
    return error.TODO;
}

/// OptionalChain[Yield, Await] : ?. Arguments[?Yield, ?Await]
/// OptionalChain[Yield, Await] : ?. [ Expression[+In, ?Yield, ?Await] ]
/// OptionalChain[Yield, Await] : ?. IdentifierName
/// OptionalChain[Yield, Await] : ?. TemplateLiteral[?Yield, ?Await, +Tagged]
/// OptionalChain[Yield, Await] : ?. PrivateIdentifier
/// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] Arguments[?Yield, ?Await]
/// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
/// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] . IdentifierName
/// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
/// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] . PrivateIdentifier
/// OptionalChain[Yield, Await] : LeftHandSideExpression[Yield, Await] :
/// OptionalChain[Yield, Await] : NewExpression[?Yield, ?Await]
/// OptionalChain[Yield, Await] : CallExpression[?Yield, ?Await]
/// OptionalChain[Yield, Await] : OptionalExpression[?Yield, ?Await]
fn parseOptionalChain(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseArguments;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parsePrivateIdentifier;
    _ = &parseLeftHandSideExpression;
    _ = &parseNewExpression;
    _ = &parseCallExpression;
    _ = &parseOptionalExpression;
    return error.TODO;
}

/// IdentifierStartChar :: UnicodeIDStart
/// IdentifierStartChar :: $
/// IdentifierStartChar :: _
fn parseIdentifierStartChar(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseUnicodeIDStart;
    return error.TODO;
}

/// UnicodeEscapeSequence :: u Hex4Digits
/// UnicodeEscapeSequence :: u{ CodePoint }
fn parseUnicodeEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseHex4Digits;
    _ = &parseCodePoint;
    return error.TODO;
}

/// IdentifierPartChar :: UnicodeIDContinue
/// IdentifierPartChar :: $
/// IdentifierPartChar :: <ZWNJ>
/// IdentifierPartChar :: <ZWJ>
fn parseIdentifierPartChar(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseUnicodeIDContinue;
    return error.TODO;
}

/// BindingElement[Yield, Await] : SingleNameBinding[?Yield, ?Await]
/// BindingElement[Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseBindingElement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseSingleNameBinding;
    _ = &parseBindingPattern;
    _ = &parseInitializer;
    return error.TODO;
}

/// MethodDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
/// MethodDefinition[Yield, Await] : GeneratorMethod[?Yield, ?Await]
/// MethodDefinition[Yield, Await] : AsyncMethod[?Yield, ?Await]
/// MethodDefinition[Yield, Await] : AsyncGeneratorMethod[?Yield, ?Await]
/// MethodDefinition[Yield, Await] : get ClassElementName[?Yield, ?Await] ( ) { FunctionBody[~Yield, ~Await] }
/// MethodDefinition[Yield, Await] : set ClassElementName[?Yield, ?Await] ( PropertySetParameterList ) { FunctionBody[~Yield, ~Await] }
fn parseMethodDefinition(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseFunctionBody;
    _ = &parseGeneratorMethod;
    _ = &parseAsyncMethod;
    _ = &parseAsyncGeneratorMethod;
    _ = &parsePropertySetParameterList;
    return error.TODO;
}

/// FieldDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseFieldDefinition(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElementName;
    _ = &parseInitializer;
    return error.TODO;
}

/// ClassStaticBlock : static { ClassStaticBlockBody }
fn parseClassStaticBlock(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseClassStaticBlockBody;
    return error.TODO;
}

/// BindingProperty[Yield, Await] : SingleNameBinding[?Yield, ?Await]
/// BindingProperty[Yield, Await] : PropertyName[?Yield, ?Await] : BindingElement[?Yield, ?Await]
fn parseBindingProperty(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseSingleNameBinding;
    _ = &parsePropertyName;
    _ = &parseBindingElement;
    return error.TODO;
}

/// BindingElisionElement[Yield, Await] : Elision? BindingElement[?Yield, ?Await]
fn parseBindingElisionElement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseElision;
    _ = &parseBindingElement;
    return error.TODO;
}

/// LogicalANDExpression[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await]
/// LogicalANDExpression[In, Yield, Await] : LogicalANDExpression[?In, ?Yield, ?Await] && BitwiseORExpression[?In, ?Yield, ?Await]
fn parseLogicalANDExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseBitwiseORExpression;
    return error.TODO;
}

/// CoalesceExpressionHead[In, Yield, Await] : CoalesceExpression[?In, ?Yield, ?Await]
/// CoalesceExpressionHead[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await]
fn parseCoalesceExpressionHead(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseCoalesceExpression;
    _ = &parseBitwiseORExpression;
    return error.TODO;
}

/// BitwiseORExpression[In, Yield, Await] : BitwiseXORExpression[?In, ?Yield, ?Await]
/// BitwiseORExpression[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await] | BitwiseXORExpression[?In, ?Yield, ?Await]
fn parseBitwiseORExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBitwiseXORExpression;
    return error.TODO;
}

/// PrimaryExpression[Yield, Await] : this
/// PrimaryExpression[Yield, Await] : IdentifierReference[?Yield, ?Await]
/// PrimaryExpression[Yield, Await] : Literal
/// PrimaryExpression[Yield, Await] : ArrayLiteral[?Yield, ?Await]
/// PrimaryExpression[Yield, Await] : ObjectLiteral[?Yield, ?Await]
/// PrimaryExpression[Yield, Await] : FunctionExpression
/// PrimaryExpression[Yield, Await] : ClassExpression[?Yield, ?Await]
/// PrimaryExpression[Yield, Await] : GeneratorExpression
/// PrimaryExpression[Yield, Await] : AsyncFunctionExpression
/// PrimaryExpression[Yield, Await] : AsyncGeneratorExpression
/// PrimaryExpression[Yield, Await] : RegularExpressionLiteral
/// PrimaryExpression[Yield, Await] : TemplateLiteral[?Yield, ?Await, ~Tagged]
/// PrimaryExpression[Yield, Await] : CoverParenthesizedExpressionAndArrowParameterList[?Yield, ?Await]
fn parsePrimaryExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseIdentifierReference;
    _ = &parseLiteral;
    _ = &parseArrayLiteral;
    _ = &parseObjectLiteral;
    _ = &parseFunctionExpression;
    _ = &parseClassExpression;
    _ = &parseGeneratorExpression;
    _ = &parseAsyncFunctionExpression;
    _ = &parseAsyncGeneratorExpression;
    _ = &parseRegularExpressionLiteral;
    _ = &parseTemplateLiteral;
    _ = &parseCoverParenthesizedExpressionAndArrowParameterList;
    return error.TODO;
}

/// SuperProperty[Yield, Await] : super [ Expression[+In, ?Yield, ?Await] ]
/// SuperProperty[Yield, Await] : super . IdentifierName
fn parseSuperProperty(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    return error.TODO;
}

/// MetaProperty : NewTarget
/// MetaProperty : ImportMeta
fn parseMetaProperty(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseNewTarget;
    _ = &parseImportMeta;
    return error.TODO;
}

/// ArgumentList[Yield, Await] : AssignmentExpression[+In, ?Yield, ?Await]
/// ArgumentList[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
/// ArgumentList[Yield, Await] : ArgumentList[?Yield, ?Await] , AssignmentExpression[+In, ?Yield, ?Await]
/// ArgumentList[Yield, Await] : ArgumentList[?Yield, ?Await] , ... AssignmentExpression[+In, ?Yield, ?Await]
fn parseArgumentList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// NoSubstitutionTemplate :: ` TemplateCharacters? `
fn parseNoSubstitutionTemplate(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseTemplateCharacters;
    return error.TODO;
}

/// SubstitutionTemplate[Yield, Await, Tagged] : TemplateHead Expression[+In, ?Yield, ?Await] TemplateSpans[?Yield, ?Await, ?Tagged]
fn parseSubstitutionTemplate(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Tagged: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Tagged;
    _ = &parseTemplateHead;
    _ = &parseExpression;
    _ = &parseTemplateSpans;
    return error.TODO;
}

///  UnicodeIDStart ::
/// any Unicode code point with the Unicode property “ID_Start”
fn parseUnicodeIDStart(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// Hex4Digits :: HexDigit HexDigit HexDigit HexDigit
fn parseHex4Digits(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseHexDigit;
    return error.TODO;
}

///  CodePoint ::
/// HexDigits[~Sep] but only if MV of HexDigits ≤ 0x10FFFF
fn parseCodePoint(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

///  UnicodeIDContinue ::
/// any Unicode code point with the Unicode property “ID_Continue”
fn parseUnicodeIDContinue(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// SingleNameBinding[Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseSingleNameBinding(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseInitializer;
    return error.TODO;
}

/// ClassElementName[Yield, Await] : PropertyName[?Yield, ?Await]
/// ClassElementName[Yield, Await] : PrivateIdentifier
fn parseClassElementName(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parsePropertyName;
    _ = &parsePrivateIdentifier;
    return error.TODO;
}

/// UniqueFormalParameters[Yield, Await] : FormalParameters[?Yield, ?Await]
fn parseUniqueFormalParameters(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseFormalParameters;
    return error.TODO;
}

/// GeneratorMethod[Yield, Await] : * ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorMethod(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseGeneratorBody;
    return error.TODO;
}

/// AsyncMethod[Yield, Await] : async [no LineTerminator here] ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncMethod(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseAsyncFunctionBody;
    return error.TODO;
}

/// AsyncGeneratorMethod[Yield, Await] : async [no LineTerminator here] * ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorMethod(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseAsyncGeneratorBody;
    return error.TODO;
}

/// PropertySetParameterList : FormalParameter[~Yield, ~Await]
fn parsePropertySetParameterList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseFormalParameter;
    return error.TODO;
}

/// ClassStaticBlockBody : ClassStaticBlockStatementList
fn parseClassStaticBlockBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseClassStaticBlockStatementList;
    return error.TODO;
}

/// PropertyName[Yield, Await] : LiteralPropertyName
/// PropertyName[Yield, Await] : ComputedPropertyName[?Yield, ?Await]
fn parsePropertyName(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseLiteralPropertyName;
    _ = &parseComputedPropertyName;
    return error.TODO;
}

/// BitwiseXORExpression[In, Yield, Await] : BitwiseANDExpression[?In, ?Yield, ?Await]
/// BitwiseXORExpression[In, Yield, Await] : BitwiseXORExpression[?In, ?Yield, ?Await] ^ BitwiseANDExpression[?In, ?Yield, ?Await]
fn parseBitwiseXORExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseBitwiseANDExpression;
    return error.TODO;
}

/// IdentifierReference[Yield, Await] : Identifier
/// IdentifierReference[Yield, Await] : [~Yield] yield
/// IdentifierReference[Yield, Await] : [~Await] await
fn parseIdentifierReference(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseIdentifier;
    return error.TODO;
}

/// Literal : NullLiteral
/// Literal : BooleanLiteral
/// Literal : NumericLiteral
/// Literal : StringLiteral
fn parseLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseNullLiteral;
    _ = &parseBooleanLiteral;
    _ = &parseNumericLiteral;
    _ = &parseStringLiteral;
    return error.TODO;
}

/// ArrayLiteral[Yield, Await] : [ Elision? ]
/// ArrayLiteral[Yield, Await] : [ ElementList[?Yield, ?Await] ]
/// ArrayLiteral[Yield, Await] : [ ElementList[?Yield, ?Await] , Elision? ]
fn parseArrayLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseElision;
    _ = &parseElementList;
    return error.TODO;
}

/// ObjectLiteral[Yield, Await] : { }
/// ObjectLiteral[Yield, Await] : { PropertyDefinitionList[?Yield, ?Await] }
/// ObjectLiteral[Yield, Await] : { PropertyDefinitionList[?Yield, ?Await] , }
fn parseObjectLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parsePropertyDefinitionList;
    return error.TODO;
}

/// FunctionExpression : function BindingIdentifier[~Yield, ~Await]? ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
fn parseFunctionExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseFunctionBody;
    return error.TODO;
}

/// ClassExpression[Yield, Await] : class BindingIdentifier[?Yield, ?Await]? ClassTail[?Yield, ?Await]
fn parseClassExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseBindingIdentifier;
    _ = &parseClassTail;
    return error.TODO;
}

/// GeneratorExpression : function * BindingIdentifier[+Yield, ~Await]? ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseGeneratorBody;
    return error.TODO;
}

/// AsyncFunctionExpression : async [no LineTerminator here] function BindingIdentifier[~Yield, +Await]? ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncFunctionExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncFunctionBody;
    return error.TODO;
}

/// AsyncGeneratorExpression : async [no LineTerminator here] function * BindingIdentifier[+Yield, +Await]? ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncGeneratorBody;
    return error.TODO;
}

/// RegularExpressionLiteral :: / RegularExpressionBody / RegularExpressionFlags
fn parseRegularExpressionLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionBody;
    _ = &parseRegularExpressionFlags;
    return error.TODO;
}

/// NewTarget : new . target
fn parseNewTarget(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// ImportMeta : import . meta
fn parseImportMeta(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// TemplateCharacters :: TemplateCharacter TemplateCharacters?
fn parseTemplateCharacters(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseTemplateCharacter;
    return error.TODO;
}

/// TemplateHead :: ` TemplateCharacters? ${
fn parseTemplateHead(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// TemplateSpans[Yield, Await, Tagged] : TemplateTail
/// TemplateSpans[Yield, Await, Tagged] : TemplateMiddleList[?Yield, ?Await, ?Tagged] TemplateTail
fn parseTemplateSpans(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Tagged: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Tagged;
    _ = &parseTemplateTail;
    _ = &parseTemplateMiddleList;
    return error.TODO;
}

///  HexDigit :: one of
/// 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F
fn parseHexDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// ClassStaticBlockStatementList : StatementList[~Yield, +Await, ~Return]?
fn parseClassStaticBlockStatementList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseStatementList;
    return error.TODO;
}

/// LiteralPropertyName : IdentifierName
/// LiteralPropertyName : StringLiteral
/// LiteralPropertyName : NumericLiteral
fn parseLiteralPropertyName(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierName;
    _ = &parseStringLiteral;
    _ = &parseNumericLiteral;
    return error.TODO;
}

/// ComputedPropertyName[Yield, Await] : [ AssignmentExpression[+In, ?Yield, ?Await] ]
fn parseComputedPropertyName(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// BitwiseANDExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await]
/// BitwiseANDExpression[In, Yield, Await] : BitwiseANDExpression[?In, ?Yield, ?Await] & EqualityExpression[?In, ?Yield, ?Await]
fn parseBitwiseANDExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseEqualityExpression;
    return error.TODO;
}

/// NullLiteral :: null
fn parseNullLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// BooleanLiteral :: true
/// BooleanLiteral :: false
fn parseBooleanLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// NumericLiteral :: DecimalLiteral
/// NumericLiteral :: DecimalBigIntegerLiteral
/// NumericLiteral :: NonDecimalIntegerLiteral[+Sep]
/// NumericLiteral :: NonDecimalIntegerLiteral[+Sep] BigIntLiteralSuffix
/// NumericLiteral :: LegacyOctalIntegerLiteral
fn parseNumericLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseDecimalLiteral;
    _ = &parseDecimalBigIntegerLiteral;
    _ = &parseNonDecimalIntegerLiteral;
    _ = &parseBigIntLiteralSuffix;
    return error.TODO;
}

/// StringLiteral :: " DoubleStringCharacters? "
/// StringLiteral :: ' SingleStringCharacters? '
fn parseStringLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseDoubleStringCharacters;
    _ = &parseSingleStringCharacters;
    return error.TODO;
}

/// ElementList[Yield, Await] : Elision? AssignmentExpression[+In, ?Yield, ?Await]
/// ElementList[Yield, Await] : Elision? SpreadElement[?Yield, ?Await]
/// ElementList[Yield, Await] : ElementList[?Yield, ?Await] , Elision? AssignmentExpression[+In, ?Yield, ?Await]
/// ElementList[Yield, Await] : ElementList[?Yield, ?Await] , Elision? SpreadElement[?Yield, ?Await]
fn parseElementList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseElision;
    _ = &parseAssignmentExpression;
    _ = &parseSpreadElement;
    return error.TODO;
}

/// PropertyDefinitionList[Yield, Await] : PropertyDefinition[?Yield, ?Await]
/// PropertyDefinitionList[Yield, Await] : PropertyDefinitionList[?Yield, ?Await] , PropertyDefinition[?Yield, ?Await]
fn parsePropertyDefinitionList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parsePropertyDefinition;
    return error.TODO;
}

/// RegularExpressionBody :: RegularExpressionFirstChar RegularExpressionChars
fn parseRegularExpressionBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionFirstChar;
    _ = &parseRegularExpressionChars;
    return error.TODO;
}

/// RegularExpressionFlags :: [empty]
/// RegularExpressionFlags :: RegularExpressionFlags IdentifierPartChar
fn parseRegularExpressionFlags(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierPartChar;
    return error.TODO;
}

/// TemplateCharacter :: $ [lookahead ≠ {]
/// TemplateCharacter :: \ TemplateEscapeSequence
/// TemplateCharacter :: \ NotEscapeSequence
/// TemplateCharacter :: LineContinuation
/// TemplateCharacter :: LineTerminatorSequence
/// TemplateCharacter :: SourceCharacter but not one of ` or \ or $ or LineTerminator
fn parseTemplateCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseTemplateEscapeSequence;
    _ = &parseNotEscapeSequence;
    _ = &parseLineContinuation;
    _ = &parseLineTerminatorSequence;
    _ = &parseSourceCharacter;
    return error.TODO;
}

/// TemplateTail :: } TemplateCharacters? `
fn parseTemplateTail(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseTemplateCharacters;
    return error.TODO;
}

/// TemplateMiddleList[Yield, Await, Tagged] : TemplateMiddle Expression[+In, ?Yield, ?Await]
/// TemplateMiddleList[Yield, Await, Tagged] : TemplateMiddleList[?Yield, ?Await, ?Tagged] TemplateMiddle Expression[+In, ?Yield, ?Await]
fn parseTemplateMiddleList(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool, comptime Tagged: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = Tagged;
    _ = &parseTemplateMiddle;
    _ = &parseExpression;
    return error.TODO;
}

/// EqualityExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] == RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] != RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] === RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] !== RelationalExpression[?In, ?Yield, ?Await]
fn parseEqualityExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseRelationalExpression;
    return error.TODO;
}

/// DecimalLiteral :: DecimalIntegerLiteral . DecimalDigits[+Sep]? ExponentPart[+Sep]?
/// DecimalLiteral :: . DecimalDigits[+Sep] ExponentPart[+Sep]?
/// DecimalLiteral :: DecimalIntegerLiteral ExponentPart[+Sep]?
fn parseDecimalLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseDecimalIntegerLiteral;
    _ = &parseDecimalDigits;
    _ = &parseExponentPart;
    return error.TODO;
}

/// DecimalBigIntegerLiteral :: 0 BigIntLiteralSuffix
/// DecimalBigIntegerLiteral :: NonZeroDigit DecimalDigits[+Sep]? BigIntLiteralSuffix
/// DecimalBigIntegerLiteral :: NonZeroDigit NumericLiteralSeparator DecimalDigits[+Sep] BigIntLiteralSuffix
fn parseDecimalBigIntegerLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseBigIntLiteralSuffix;
    _ = &parseNonZeroDigit;
    _ = &parseDecimalDigits;
    _ = &parseNumericLiteralSeparator;
    return error.TODO;
}

/// NonDecimalIntegerLiteral[Sep] :: BinaryIntegerLiteral[?Sep]
/// NonDecimalIntegerLiteral[Sep] :: OctalIntegerLiteral[?Sep]
/// NonDecimalIntegerLiteral[Sep] :: HexIntegerLiteral[?Sep]
fn parseNonDecimalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseBinaryIntegerLiteral;
    _ = &parseOctalIntegerLiteral;
    _ = &parseHexIntegerLiteral;
    return error.TODO;
}

/// BigIntLiteralSuffix :: n
fn parseBigIntLiteralSuffix(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// DoubleStringCharacters :: DoubleStringCharacter DoubleStringCharacters?
fn parseDoubleStringCharacters(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseDoubleStringCharacter;
    return error.TODO;
}

/// SingleStringCharacters :: SingleStringCharacter SingleStringCharacters?
fn parseSingleStringCharacters(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseSingleStringCharacter;
    return error.TODO;
}

/// SpreadElement[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
fn parseSpreadElement(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// PropertyDefinition[Yield, Await] : IdentifierReference[?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : CoverInitializedName[?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : PropertyName[?Yield, ?Await] : AssignmentExpression[+In, ?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : MethodDefinition[?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
fn parsePropertyDefinition(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseIdentifierReference;
    _ = &parseCoverInitializedName;
    _ = &parsePropertyName;
    _ = &parseAssignmentExpression;
    _ = &parseMethodDefinition;
    return error.TODO;
}

/// RegularExpressionFirstChar :: RegularExpressionNonTerminator but not one of * or \ or / or [
/// RegularExpressionFirstChar :: RegularExpressionBackslashSequence
/// RegularExpressionFirstChar :: RegularExpressionClass
fn parseRegularExpressionFirstChar(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionNonTerminator;
    _ = &parseRegularExpressionBackslashSequence;
    _ = &parseRegularExpressionClass;
    return error.TODO;
}

/// RegularExpressionChars :: [empty]
/// RegularExpressionChars :: RegularExpressionChars RegularExpressionChar
fn parseRegularExpressionChars(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionChar;
    return error.TODO;
}

/// TemplateEscapeSequence :: CharacterEscapeSequence
/// TemplateEscapeSequence :: 0 [lookahead ∉ DecimalDigit]
/// TemplateEscapeSequence :: HexEscapeSequence
/// TemplateEscapeSequence :: UnicodeEscapeSequence
fn parseTemplateEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseCharacterEscapeSequence;
    _ = &parseDecimalDigit;
    _ = &parseHexEscapeSequence;
    _ = &parseUnicodeEscapeSequence;
    return error.TODO;
}

/// NotEscapeSequence :: 0 DecimalDigit
/// NotEscapeSequence :: DecimalDigit but not 0
/// NotEscapeSequence :: x [lookahead ∉ HexDigit]
/// NotEscapeSequence :: x HexDigit [lookahead ∉ HexDigit]
/// NotEscapeSequence :: u [lookahead ∉ HexDigit] [lookahead ≠ {]
/// NotEscapeSequence :: u HexDigit [lookahead ∉ HexDigit]
/// NotEscapeSequence :: u HexDigit HexDigit [lookahead ∉ HexDigit]
/// NotEscapeSequence :: u HexDigit HexDigit HexDigit [lookahead ∉ HexDigit]
/// NotEscapeSequence :: u { [lookahead ∉ HexDigit]
/// NotEscapeSequence :: u { NotCodePoint [lookahead ∉ HexDigit]
/// NotEscapeSequence :: u { CodePoint [lookahead ∉ HexDigit] [lookahead ≠ }]
fn parseNotEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseDecimalDigit;
    _ = &parseHexDigit;
    _ = &parseNotCodePoint;
    _ = &parseCodePoint;
    return error.TODO;
}

/// LineContinuation :: \ LineTerminatorSequence
fn parseLineContinuation(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseLineTerminatorSequence;
    return error.TODO;
}

/// LineTerminatorSequence :: <LF>
/// LineTerminatorSequence :: <CR> [lookahead ≠ <LF>]
/// LineTerminatorSequence :: <LS>
/// LineTerminatorSequence :: <PS>
/// LineTerminatorSequence :: <CR> <LF>
fn parseLineTerminatorSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

///  SourceCharacter ::
/// any Unicode code point
fn parseSourceCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// TemplateMiddle :: } TemplateCharacters? ${
fn parseTemplateMiddle(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseTemplateCharacters;
    return error.TODO;
}

/// RelationalExpression[In, Yield, Await] : ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] < ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] > ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] <= ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] >= ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] instanceof ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : [+In] RelationalExpression[+In, ?Yield, ?Await] in ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : [+In] PrivateIdentifier in ShiftExpression[?Yield, ?Await]
fn parseRelationalExpression(alloc: std.mem.Allocator, p: *Parser, comptime In: bool, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = In;
    _ = Yield;
    _ = Await;
    _ = &parseShiftExpression;
    _ = &parsePrivateIdentifier;
    return error.TODO;
}

/// DecimalIntegerLiteral :: 0
/// DecimalIntegerLiteral :: NonZeroDigit
/// DecimalIntegerLiteral :: NonZeroDigit NumericLiteralSeparator? DecimalDigits[+Sep]
/// DecimalIntegerLiteral :: NonOctalDecimalIntegerLiteral
fn parseDecimalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseNonZeroDigit;
    _ = &parseNumericLiteralSeparator;
    _ = &parseDecimalDigits;
    _ = &parseNonOctalDecimalIntegerLiteral;
    return error.TODO;
}

/// DecimalDigits[Sep] :: DecimalDigit
/// DecimalDigits[Sep] :: DecimalDigits[?Sep] DecimalDigit
/// DecimalDigits[Sep] :: [+Sep] DecimalDigits[+Sep] NumericLiteralSeparator DecimalDigit
fn parseDecimalDigits(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseDecimalDigit;
    _ = &parseNumericLiteralSeparator;
    return error.TODO;
}

/// ExponentPart[Sep] :: ExponentIndicator SignedInteger[?Sep]
fn parseExponentPart(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseExponentIndicator;
    _ = &parseSignedInteger;
    return error.TODO;
}

///  NonZeroDigit :: one of
/// 1 2 3 4 5 6 7 8 9
fn parseNonZeroDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// NumericLiteralSeparator :: _
fn parseNumericLiteralSeparator(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// BinaryIntegerLiteral[Sep] :: 0b BinaryDigits[?Sep]
/// BinaryIntegerLiteral[Sep] :: 0B BinaryDigits[?Sep]
fn parseBinaryIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseBinaryDigits;
    return error.TODO;
}

/// OctalIntegerLiteral[Sep] :: 0o OctalDigits[?Sep]
/// OctalIntegerLiteral[Sep] :: 0O OctalDigits[?Sep]
fn parseOctalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseOctalDigits;
    return error.TODO;
}

/// HexIntegerLiteral[Sep] :: 0x HexDigits[?Sep]
/// HexIntegerLiteral[Sep] :: 0X HexDigits[?Sep]
fn parseHexIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseHexDigits;
    return error.TODO;
}

/// DoubleStringCharacter :: SourceCharacter but not one of " or \ or LineTerminator
/// DoubleStringCharacter :: <LS>
/// DoubleStringCharacter :: <PS>
/// DoubleStringCharacter :: \ EscapeSequence
/// DoubleStringCharacter :: LineContinuation
fn parseDoubleStringCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseEscapeSequence;
    _ = &parseLineContinuation;
    return error.TODO;
}

/// SingleStringCharacter :: SourceCharacter but not one of ' or \ or LineTerminator
/// SingleStringCharacter :: <LS>
/// SingleStringCharacter :: <PS>
/// SingleStringCharacter :: \ EscapeSequence
/// SingleStringCharacter :: LineContinuation
fn parseSingleStringCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseEscapeSequence;
    _ = &parseLineContinuation;
    return error.TODO;
}

/// CoverInitializedName[Yield, Await] : IdentifierReference[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]
fn parseCoverInitializedName(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseIdentifierReference;
    _ = &parseInitializer;
    return error.TODO;
}

///  RegularExpressionNonTerminator ::
/// SourceCharacter but not LineTerminator
fn parseRegularExpressionNonTerminator(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// RegularExpressionBackslashSequence :: \ RegularExpressionNonTerminator
fn parseRegularExpressionBackslashSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionNonTerminator;
    return error.TODO;
}

/// RegularExpressionClass :: [ RegularExpressionClassChars ]
fn parseRegularExpressionClass(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionClassChars;
    return error.TODO;
}

/// RegularExpressionChar :: RegularExpressionNonTerminator but not one of \ or / or [
/// RegularExpressionChar :: RegularExpressionBackslashSequence
/// RegularExpressionChar :: RegularExpressionClass
fn parseRegularExpressionChar(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionNonTerminator;
    _ = &parseRegularExpressionBackslashSequence;
    _ = &parseRegularExpressionClass;
    return error.TODO;
}

/// CharacterEscapeSequence :: SingleEscapeCharacter
/// CharacterEscapeSequence :: NonEscapeCharacter
fn parseCharacterEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseSingleEscapeCharacter;
    _ = &parseNonEscapeCharacter;
    return error.TODO;
}

///  DecimalDigit :: one of
/// 0 1 2 3 4 5 6 7 8 9
fn parseDecimalDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// HexEscapeSequence :: x HexDigit HexDigit
fn parseHexEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseHexDigit;
    return error.TODO;
}

/// NotCodePoint :: HexDigits[~Sep] but only if MV of HexDigits > 0x10FFFF
fn parseNotCodePoint(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// ShiftExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await]
/// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] << AdditiveExpression[?Yield, ?Await]
/// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] >> AdditiveExpression[?Yield, ?Await]
/// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] >>> AdditiveExpression[?Yield, ?Await]
fn parseShiftExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseAdditiveExpression;
    return error.TODO;
}

/// NonOctalDecimalIntegerLiteral :: 0 NonOctalDigit
/// NonOctalDecimalIntegerLiteral :: LegacyOctalLikeDecimalIntegerLiteral NonOctalDigit
/// NonOctalDecimalIntegerLiteral :: NonOctalDecimalIntegerLiteral DecimalDigit
fn parseNonOctalDecimalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseNonOctalDigit;
    _ = &parseDecimalDigit;
    return error.TODO;
}

///  ExponentIndicator :: one of
/// e E
fn parseExponentIndicator(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// SignedInteger[Sep] :: DecimalDigits[?Sep]
/// SignedInteger[Sep] :: + DecimalDigits[?Sep]
/// SignedInteger[Sep] :: - DecimalDigits[?Sep]
fn parseSignedInteger(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseDecimalDigits;
    return error.TODO;
}

/// BinaryDigits[Sep] :: BinaryDigit
/// BinaryDigits[Sep] :: BinaryDigits[?Sep] BinaryDigit
/// BinaryDigits[Sep] :: [+Sep] BinaryDigits[+Sep] NumericLiteralSeparator BinaryDigit
fn parseBinaryDigits(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseBinaryDigit;
    _ = &parseNumericLiteralSeparator;
    return error.TODO;
}

/// OctalDigits[Sep] :: OctalDigit
/// OctalDigits[Sep] :: OctalDigits[?Sep] OctalDigit
/// OctalDigits[Sep] :: [+Sep] OctalDigits[+Sep] NumericLiteralSeparator OctalDigit
fn parseOctalDigits(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseOctalDigit;
    _ = &parseNumericLiteralSeparator;
    return error.TODO;
}

/// HexDigits[Sep] :: HexDigit
/// HexDigits[Sep] :: HexDigits[?Sep] HexDigit
/// HexDigits[Sep] :: [+Sep] HexDigits[+Sep] NumericLiteralSeparator HexDigit
fn parseHexDigits(alloc: std.mem.Allocator, p: *Parser, comptime Sep: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Sep;
    _ = &parseHexDigit;
    _ = &parseNumericLiteralSeparator;
    return error.TODO;
}

/// EscapeSequence :: CharacterEscapeSequence
/// EscapeSequence :: 0 [lookahead ∉ DecimalDigit]
/// EscapeSequence :: LegacyOctalEscapeSequence
/// EscapeSequence :: NonOctalDecimalEscapeSequence
/// EscapeSequence :: HexEscapeSequence
/// EscapeSequence :: UnicodeEscapeSequence
fn parseEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseCharacterEscapeSequence;
    _ = &parseNonOctalDecimalEscapeSequence;
    _ = &parseHexEscapeSequence;
    _ = &parseUnicodeEscapeSequence;
    return error.TODO;
}

/// RegularExpressionClassChars :: [empty]
/// RegularExpressionClassChars :: RegularExpressionClassChars RegularExpressionClassChar
fn parseRegularExpressionClassChars(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionClassChar;
    return error.TODO;
}

///  SingleEscapeCharacter :: one of
/// ' " \ b f n r t v
fn parseSingleEscapeCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// NonEscapeCharacter :: SourceCharacter but not one of EscapeCharacter or LineTerminator
fn parseNonEscapeCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// AdditiveExpression[Yield, Await] : MultiplicativeExpression[?Yield, ?Await]
/// AdditiveExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await] + MultiplicativeExpression[?Yield, ?Await]
/// AdditiveExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await] - MultiplicativeExpression[?Yield, ?Await]
fn parseAdditiveExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseMultiplicativeExpression;
    return error.TODO;
}

///  NonOctalDigit :: one of
/// 8 9
fn parseNonOctalDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

///  BinaryDigit :: one of
/// 0 1
fn parseBinaryDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

///  OctalDigit :: one of
/// 0 1 2 3 4 5 6 7
fn parseOctalDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

///  NonOctalDecimalEscapeSequence :: one of
/// 8 9
fn parseNonOctalDecimalEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// RegularExpressionClassChar :: RegularExpressionNonTerminator but not one of ] or \
/// RegularExpressionClassChar :: RegularExpressionBackslashSequence
fn parseRegularExpressionClassChar(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseRegularExpressionNonTerminator;
    _ = &parseRegularExpressionBackslashSequence;
    return error.TODO;
}

/// MultiplicativeExpression[Yield, Await] : ExponentiationExpression[?Yield, ?Await]
/// MultiplicativeExpression[Yield, Await] : MultiplicativeExpression[?Yield, ?Await] MultiplicativeOperator ExponentiationExpression[?Yield, ?Await]
fn parseMultiplicativeExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseExponentiationExpression;
    _ = &parseMultiplicativeOperator;
    return error.TODO;
}

/// ExponentiationExpression[Yield, Await] : UnaryExpression[?Yield, ?Await]
/// ExponentiationExpression[Yield, Await] : UpdateExpression[?Yield, ?Await] ** ExponentiationExpression[?Yield, ?Await]
fn parseExponentiationExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseUnaryExpression;
    _ = &parseUpdateExpression;
    return error.TODO;
}

///  MultiplicativeOperator : one of
/// * / %
fn parseMultiplicativeOperator(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// UnaryExpression[Yield, Await] : UpdateExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : delete UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : void UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : typeof UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : + UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : - UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : ~ UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : ! UnaryExpression[?Yield, ?Await]
/// UnaryExpression[Yield, Await] : [+Await] AwaitExpression[?Yield]
fn parseUnaryExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseUpdateExpression;
    _ = &parseAwaitExpression;
    return error.TODO;
}

/// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await]
/// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await] [no LineTerminator here] ++
/// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await] [no LineTerminator here] --
/// UpdateExpression[Yield, Await] : ++ UnaryExpression[?Yield, ?Await]
/// UpdateExpression[Yield, Await] : -- UnaryExpression[?Yield, ?Await]
fn parseUpdateExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool, comptime Await: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = Await;
    _ = &parseLeftHandSideExpression;
    _ = &parseUnaryExpression;
    return error.TODO;
}

/// AwaitExpression[Yield] : await UnaryExpression[?Yield, +Await]
fn parseAwaitExpression(alloc: std.mem.Allocator, p: *Parser, comptime Yield: bool) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = Yield;
    _ = &parseUnaryExpression;
    return error.TODO;
}

/// Module : ModuleBody?
fn parseModule(alloc: std.mem.Allocator, p: *Parser) !void {
    //
    _ = alloc;
    _ = p;
    _ = &parseModuleBody;
    return error.TODO;
}

/// ModuleBody : ModuleItemList
fn parseModuleBody(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseModuleItemList;
    return error.TODO;
}

/// ModuleItemList : ModuleItem
/// ModuleItemList : ModuleItemList ModuleItem
fn parseModuleItemList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseModuleItem;
    return error.TODO;
}

/// ModuleItem : ImportDeclaration
/// ModuleItem : ExportDeclaration
/// ModuleItem : StatementListItem[~Yield, +Await, ~Return]
fn parseModuleItem(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportDeclaration;
    _ = &parseExportDeclaration;
    _ = &parseStatementListItem;
    return error.TODO;
}

/// ImportDeclaration : import ImportClause FromClause ;
/// ImportDeclaration : import ModuleSpecifier ;
fn parseImportDeclaration(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportClause;
    _ = &parseFromClause;
    _ = &parseModuleSpecifier;
    return error.TODO;
}

/// ExportDeclaration : export ExportFromClause FromClause ;
/// ExportDeclaration : export NamedExports ;
/// ExportDeclaration : export VariableStatement[~Yield, +Await]
/// ExportDeclaration : export Declaration[~Yield, +Await]
/// ExportDeclaration : export default HoistableDeclaration[~Yield, +Await, +Default]
/// ExportDeclaration : export default ClassDeclaration[~Yield, +Await, +Default]
/// ExportDeclaration : export default [lookahead ∉ { function, async [no LineTerminator here] function, class }] AssignmentExpression[+In, ~Yield, +Await] ;
fn parseExportDeclaration(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseExportFromClause;
    _ = &parseFromClause;
    _ = &parseVariableStatement;
    _ = &parseDeclaration;
    _ = &parseHoistableDeclaration;
    _ = &parseClassDeclaration;
    _ = &parseAssignmentExpression;
    return error.TODO;
}

/// ImportClause : ImportedDefaultBinding
/// ImportClause : NameSpaceImport
/// ImportClause : NamedImports
/// ImportClause : ImportedDefaultBinding , NameSpaceImport
/// ImportClause : ImportedDefaultBinding , NamedImports
fn parseImportClause(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportedDefaultBinding;
    _ = &parseNameSpaceImport;
    _ = &parseNamedImports;
    return error.TODO;
}

/// FromClause : from ModuleSpecifier
fn parseFromClause(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseModuleSpecifier;
    return error.TODO;
}

/// ModuleSpecifier : StringLiteral
fn parseModuleSpecifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = parseStringLiteral;
    return error.TODO;
}

/// ExportFromClause : *
/// ExportFromClause : * as ModuleExportName
/// ExportFromClause : NamedExports
fn parseExportFromClause(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseModuleExportName;
    _ = &parseNamedExports;
    return error.TODO;
}

/// ImportedDefaultBinding : ImportedBinding
fn parseImportedDefaultBinding(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportedBinding;
    return error.TODO;
}

/// NameSpaceImport : * as ImportedBinding
fn parseNameSpaceImport(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportedBinding;
    return error.TODO;
}

/// NamedImports : { }
/// NamedImports : { ImportsList }
/// NamedImports : { ImportsList , }
fn parseNamedImports(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportsList;
    return error.TODO;
}

/// ModuleExportName : IdentifierName
/// ModuleExportName : StringLiteral
fn parseModuleExportName(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseIdentifierName;
    _ = &parseStringLiteral;
    return error.TODO;
}

/// NamedExports : { }
/// NamedExports : { ExportsList }
/// NamedExports : { ExportsList , }
fn parseNamedExports(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// ImportedBinding : BindingIdentifier[~Yield, +Await]
fn parseImportedBinding(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseBindingIdentifier;
    return error.TODO;
}

/// ImportsList : ImportSpecifier
/// ImportsList : ImportsList , ImportSpecifier
fn parseImportsList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportSpecifier;
    return error.TODO;
}

/// ExportsList : ExportSpecifier
/// ExportsList : ExportsList , ExportSpecifier
fn parseExportsList(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseExportSpecifier;
    return error.TODO;
}

/// ImportSpecifier : ImportedBinding
/// ImportSpecifier : ModuleExportName as ImportedBinding
fn parseImportSpecifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseImportedBinding;
    _ = &parseModuleExportName;
    return error.TODO;
}

/// ExportSpecifier : ModuleExportName
/// ExportSpecifier : ModuleExportName as ModuleExportName
fn parseExportSpecifier(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    _ = &parseModuleExportName;
    return error.TODO;
}

/// LineTerminator :: <LF>
/// LineTerminator :: <CR>
/// LineTerminator :: <LS>
/// LineTerminator :: <PS>
fn parseLineTerminator(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}

/// EscapeCharacter :: SingleEscapeCharacter
/// EscapeCharacter :: DecimalDigit
/// EscapeCharacter :: x
/// EscapeCharacter :: u
fn parseEscapeCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!?void {
    //
    _ = alloc;
    _ = p;
    return error.TODO;
}
