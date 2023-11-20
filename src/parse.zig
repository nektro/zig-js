//! A streaming parser for ECMAScript.
//!
//! grammar rules current as of Draft ECMA-262 / November 3, 2023
//! https://tc39.es/ecma262/

const std = @import("std");
const string = []const u8;
const Parser = @import("./Parser.zig");
const extras = @import("extras");
const unicodeucd = @import("unicode-ucd");
const tracer = @import("tracer");

inline fn w(val: anytype) ?W(@TypeOf(val)) {
    return val catch null;
}

fn W(comptime T: type) type {
    return switch (@typeInfo(T)) {
        .ErrorUnion => |v| v.payload,
        else => unreachable,
    };
}

pub fn do(alloc: std.mem.Allocator, path: string, inreader: anytype, isModule: bool) !void {
    //
    const t = tracer.trace(@src(), "", .{});
    defer t.end();

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
    return try parseScript(alloc, &p);
}

/// Script : ScriptBody
fn parseScript(alloc: std.mem.Allocator, p: *Parser) !void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseScriptBody(alloc, p);
}

/// ScriptBody : StatementList[~Yield, ~Await, ~Return]?
fn parseScriptBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseStatementList(alloc, p, false, false, false);
}

/// StatementList[Yield, Await, Return] : StatementListItem[?Yield, ?Await, ?Return]
/// StatementList[Yield, Await, Return] : StatementList[?Yield, ?Await, ?Return] StatementListItem[?Yield, ?Await, ?Return]
fn parseStatementList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        _ = parseStatementListItem(alloc, p, Yield, Await, Return) catch if (i == 0) return error.JsMalformed else break;
        if (p.end) break;
    }
}

/// StatementListItem[Yield, Await, Return] : Statement[?Yield, ?Await, ?Return]
/// StatementListItem[Yield, Await, Return] : Declaration[?Yield, ?Await]
fn parseStatementListItem(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseDeclaration(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
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
fn parseStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseBlockStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseVariableStatement(alloc, p, Yield, Await))) |_| return;
    if (w(parseEmptyStatement(alloc, p))) |_| return;
    if (w(parseIfStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseBreakableStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseContinueStatement(alloc, p, Yield, Await))) |_| return;
    if (w(parseBreakStatement(alloc, p, Yield, Await))) |_| return;
    if (Return) if (w(parseReturnStatement(alloc, p, Yield, Await))) |_| return;
    if (w(parseLabelledStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseThrowStatement(alloc, p, Yield, Await))) |_| return;
    if (w(parseTryStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseDebuggerStatement(alloc, p))) |_| return;
    if (w(parseExpressionStatement(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// Declaration[Yield, Await] : HoistableDeclaration[?Yield, ?Await, ~Default]
/// Declaration[Yield, Await] : ClassDeclaration[?Yield, ?Await, ~Default]
/// Declaration[Yield, Await] : LexicalDeclaration[+In, ?Yield, ?Await]
fn parseDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseHoistableDeclaration(alloc, p, Yield, Await, false))) |_| return;
    if (w(parseClassDeclaration(alloc, p, Yield, Await, false))) |_| return;
    if (w(parseLexicalDeclaration(alloc, p, true, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// BlockStatement[Yield, Await, Return] : Block[?Yield, ?Await, ?Return]
fn parseBlockStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseBlock(alloc, p, Yield, Await, Return);
}

/// VariableStatement[Yield, Await] : var VariableDeclarationList[+In, ?Yield, ?Await] ;
fn parseVariableStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("var");
    _ = try parseVariableDeclarationList(alloc, p, true, Yield, Await);
    try p.eatTok(";");
}

/// EmptyStatement : ;
fn parseEmptyStatement(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    return p.eatTok(";");
}

/// ExpressionStatement[Yield, Await] : [lookahead ∉ { {, function, async [no LineTerminator here] function, class, let [ }] Expression[+In, ?Yield, ?Await] ;
fn parseExpressionStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;

    _ = blk: {
        errdefer p.idx = old_idx;
        p.eatTok("{") catch break :blk;
        return error.JsMalformed;
    };
    _ = blk: {
        errdefer p.idx = old_idx;
        p.eatTok("function") catch break :blk;
        return error.JsMalformed;
    };
    _ = blk: {
        errdefer p.idx = old_idx;
        p.eatTok("async") catch break :blk;
        p.eatTok("function") catch break :blk;
        return error.JsMalformed;
    };
    _ = blk: {
        errdefer p.idx = old_idx;
        p.eatTok("class") catch break :blk;
        return error.JsMalformed;
    };
    _ = blk: {
        errdefer p.idx = old_idx;
        p.eatTok("let") catch break :blk;
        p.eatTok("[") catch break :blk;
        return error.JsMalformed;
    };
    p.idx = old_idx;

    errdefer p.idx = old_idx;
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(";");
}

/// IfStatement[Yield, Await, Return] : if ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return] else Statement[?Yield, ?Await, ?Return]
/// IfStatement[Yield, Await, Return] : if ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return] [lookahead ≠ else]
fn parseIfStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("if");
    try p.eatTok("(");
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(")");
    _ = try parseStatement(alloc, p, Yield, Await, Return);
    p.eatTok("else") catch return;
    _ = try parseStatement(alloc, p, Yield, Await, Return);
}

/// BreakableStatement[Yield, Await, Return] : IterationStatement[?Yield, ?Await, ?Return]
/// BreakableStatement[Yield, Await, Return] : SwitchStatement[?Yield, ?Await, ?Return]
fn parseBreakableStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseIterationStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseSwitchStatement(alloc, p, Yield, Await, Return))) |_| return;
    return error.JsMalformed;
}

/// ContinueStatement[Yield, Await] : continue ;
/// ContinueStatement[Yield, Await] : continue [no LineTerminator here] LabelIdentifier[?Yield, ?Await] ;
fn parseContinueStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("continue");
    if (w(p.eatTok(";"))) |_| return;
    _ = try parseLabelIdentifier(alloc, p, Yield, Await);
    try p.eatTok(";");
}

/// BreakStatement[Yield, Await] : break ;
/// BreakStatement[Yield, Await] : break [no LineTerminator here] LabelIdentifier[?Yield, ?Await] ;
fn parseBreakStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("break");
    if (w(p.eatTok(";"))) |_| return;
    _ = try parseLabelIdentifier(alloc, p, Yield, Await);
    try p.eatTok(";");
}

/// ReturnStatement[Yield, Await] : return ;
/// ReturnStatement[Yield, Await] : return [no LineTerminator here] Expression[+In, ?Yield, ?Await] ;
fn parseReturnStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("return");
    if (w(p.eatTok(";"))) |_| return;
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(";");
}

/// LabelledStatement[Yield, Await, Return] : LabelIdentifier[?Yield, ?Await] : LabelledItem[?Yield, ?Await, ?Return]
fn parseLabelledStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseLabelIdentifier(alloc, p, Yield, Await);
    try p.eatTok(":");
    _ = try parseLabelledItem(alloc, p, Yield, Await, Return);
}

/// ThrowStatement[Yield, Await] : throw [no LineTerminator here] Expression[+In, ?Yield, ?Await] ;
fn parseThrowStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("throw");
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(";");
}

/// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Catch[?Yield, ?Await, ?Return]
/// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Finally[?Yield, ?Await, ?Return]
/// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Catch[?Yield, ?Await, ?Return] Finally[?Yield, ?Await, ?Return]
fn parseTryStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("try");
    _ = try parseBlock(alloc, p, Yield, Await, Return);
    if (w(parseFinally(alloc, p, Yield, Await, Return))) |_| return;
    _ = try parseCatch(alloc, p, Yield, Await, Return);
    if (w(parseFinally(alloc, p, Yield, Await, Return))) |_| return;
}

/// DebuggerStatement : debugger ;
fn parseDebuggerStatement(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    try p.eatTok("debugger");
    try p.eatTok(";");
}

/// HoistableDeclaration[Yield, Await, Default] : FunctionDeclaration[?Yield, ?Await, ?Default]
/// HoistableDeclaration[Yield, Await, Default] : GeneratorDeclaration[?Yield, ?Await, ?Default]
/// HoistableDeclaration[Yield, Await, Default] : AsyncFunctionDeclaration[?Yield, ?Await, ?Default]
/// HoistableDeclaration[Yield, Await, Default] : AsyncGeneratorDeclaration[?Yield, ?Await, ?Default]
fn parseHoistableDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Default: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseFunctionDeclaration(alloc, p, Yield, Await, Default))) |_| return;
    if (w(parseGeneratorDeclaration(alloc, p, Yield, Await, Default))) |_| return;
    if (w(parseAsyncFunctionDeclaration(alloc, p, Yield, Await, Default))) |_| return;
    if (w(parseAsyncGeneratorDeclaration(alloc, p, Yield, Await, Default))) |_| return;
    return error.JsMalformed;
}

/// ClassDeclaration[Yield, Await, Default] : class BindingIdentifier[?Yield, ?Await] ClassTail[?Yield, ?Await]
/// ClassDeclaration[Yield, Await, Default] : [+Default] class ClassTail[?Yield, ?Await]
fn parseClassDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Default: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("class");
    _ = if (!Default) try parseBindingIdentifier(alloc, p, Yield, Await);
    _ = try parseClassTail(alloc, p, Yield, Await);
}

/// LexicalDeclaration[In, Yield, Await] : LetOrConst BindingList[?In, ?Yield, ?Await] ;
fn parseLexicalDeclaration(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseLetOrConst(alloc, p);
    _ = try parseBindingList(alloc, p, In, Yield, Await);
    try p.eatTok(";");
}

/// Block[Yield, Await, Return] : { StatementList[?Yield, ?Await, ?Return]? }
fn parseBlock(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("{");
    _ = parseStatementList(alloc, p, Yield, Await, Return) catch {};
    try p.eatTok("}");
}

/// VariableDeclarationList[In, Yield, Await] : VariableDeclaration[?In, ?Yield, ?Await]
/// VariableDeclarationList[In, Yield, Await] : VariableDeclarationList[?In, ?Yield, ?Await] , VariableDeclaration[?In, ?Yield, ?Await]
fn parseVariableDeclarationList(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = try parseVariableDeclaration(alloc, p, In, Yield, Await);
        p.eatTok(",") catch break;
    }
}

/// Expression[In, Yield, Await] : AssignmentExpression[?In, ?Yield, ?Await]
/// Expression[In, Yield, Await] : Expression[?In, ?Yield, ?Await] , AssignmentExpression[?In, ?Yield, ?Await]
fn parseExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = try parseAssignmentExpression(alloc, p, In, Yield, Await);
        p.eatTok(",") catch break;
    }
}

/// IterationStatement[Yield, Await, Return] : DoWhileStatement[?Yield, ?Await, ?Return]
/// IterationStatement[Yield, Await, Return] : WhileStatement[?Yield, ?Await, ?Return]
/// IterationStatement[Yield, Await, Return] : ForStatement[?Yield, ?Await, ?Return]
/// IterationStatement[Yield, Await, Return] : ForInOfStatement[?Yield, ?Await, ?Return]
fn parseIterationStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseDoWhileStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseWhileStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseForStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseForInOfStatement(alloc, p, Yield, Await, Return))) |_| return;
    return error.JsMalformed;
}

/// SwitchStatement[Yield, Await, Return] : switch ( Expression[+In, ?Yield, ?Await] ) CaseBlock[?Yield, ?Await, ?Return]
fn parseSwitchStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("switch");
    try p.eatTok("(");
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(")");
    _ = try parseCaseBlock(alloc, p, Yield, Await, Return);
}

/// LabelIdentifier[Yield, Await] : Identifier
/// LabelIdentifier[Yield, Await] : [~Yield] yield
/// LabelIdentifier[Yield, Await] : [~Await] await
fn parseLabelIdentifier(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (!Yield) if (w(p.eatTok("yield"))) |_| return;
    if (!Await) if (w(p.eatTok("await"))) |_| return;
    if (w(parseIdentifier(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// LabelledItem[Yield, Await, Return] : Statement[?Yield, ?Await, ?Return]
/// LabelledItem[Yield, Await, Return] : FunctionDeclaration[?Yield, ?Await, ~Default]
fn parseLabelledItem(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseStatement(alloc, p, Yield, Await, Return))) |_| return;
    if (w(parseFunctionDeclaration(alloc, p, Yield, Await, false))) |_| return;
    return error.JsMalformed;
}

/// Catch[Yield, Await, Return] : catch ( CatchParameter[?Yield, ?Await] ) Block[?Yield, ?Await, ?Return]
/// Catch[Yield, Await, Return] : catch Block[?Yield, ?Await, ?Return]
fn parseCatch(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("catch");
    if (w(p.eatTok("("))) |_| {
        _ = try parseCatchParameter(alloc, p, Yield, Await);
        try p.eatTok(")");
    }
    _ = try parseBlock(alloc, p, Yield, Await, Return);
}

/// Finally[Yield, Await, Return] : finally Block[?Yield, ?Await, ?Return]
fn parseFinally(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("finally");
    _ = try parseBlock(alloc, p, Yield, Await, Return);
}

/// FunctionDeclaration[Yield, Await, Default] : function BindingIdentifier[?Yield, ?Await] ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
/// FunctionDeclaration[Yield, Await, Default] : [+Default] function ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
fn parseFunctionDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Default: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("function");
    _ = if (!Default) try parseBindingIdentifier(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, false, false);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseFunctionBody(alloc, p, false, false);
    try p.eatTok("}");
}

/// GeneratorDeclaration[Yield, Await, Default] : function * BindingIdentifier[?Yield, ?Await] ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
/// GeneratorDeclaration[Yield, Await, Default] : [+Default] function * ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Default: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("function");
    try p.eatTok("*");
    _ = if (!Default) try parseBindingIdentifier(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, true, false);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseGeneratorBody(alloc, p);
    try p.eatTok("}");
}

/// AsyncFunctionDeclaration[Yield, Await, Default] : async [no LineTerminator here] function BindingIdentifier[?Yield, ?Await] ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
/// AsyncFunctionDeclaration[Yield, Await, Default] : [+Default] async [no LineTerminator here] function ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncFunctionDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Default: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("async");
    try p.eatTok("function");
    _ = if (!Default) try parseBindingIdentifier(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, false, true);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseAsyncFunctionBody(alloc, p);
    try p.eatTok("}");
}

/// AsyncGeneratorDeclaration[Yield, Await, Default] : async [no LineTerminator here] function * BindingIdentifier[?Yield, ?Await] ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
/// AsyncGeneratorDeclaration[Yield, Await, Default] : [+Default] async [no LineTerminator here] function * ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Default: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("async");
    try p.eatTok("function");
    try p.eatTok("*");
    _ = if (!Default) try parseBindingIdentifier(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, true, true);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseAsyncGeneratorBody(alloc, p);
    try p.eatTok("}");
}

/// BindingIdentifier[Yield, Await] : Identifier
/// BindingIdentifier[Yield, Await] : yield
/// BindingIdentifier[Yield, Await] : await
fn parseBindingIdentifier(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = Yield;
    _ = Await;
    if (w(p.eatTok("yield"))) |_| return;
    if (w(p.eatTok("await"))) |_| return;
    if (w(parseIdentifier(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// ClassTail[Yield, Await] : ClassHeritage[?Yield, ?Await]? { ClassBody[?Yield, ?Await]? }
fn parseClassTail(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = parseClassHeritage(alloc, p, Yield, Await) catch null;
    try p.eatTok("{");
    _ = parseClassBody(alloc, p, Yield, Await) catch null;
    try p.eatTok("}");
}

/// LetOrConst : let
/// LetOrConst : const
fn parseLetOrConst(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatTok("let"))) |_| return;
    if (w(p.eatTok("const"))) |_| return;
    return error.JsMalformed;
}

/// BindingList[In, Yield, Await] : LexicalBinding[?In, ?Yield, ?Await]
/// BindingList[In, Yield, Await] : BindingList[?In, ?Yield, ?Await] , LexicalBinding[?In, ?Yield, ?Await]
fn parseBindingList(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = try parseLexicalBinding(alloc, p, In, Yield, Await);
        p.eatTok(",") catch break;
    }
}

/// VariableDeclaration[In, Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]?
/// VariableDeclaration[In, Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]
fn parseVariableDeclaration(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = parseBindingIdentifier(alloc, p, Yield, Await) catch {
        _ = try parseBindingPattern(alloc, p, Yield, Await);
        _ = try parseInitializer(alloc, p, In, Yield, Await);
        return;
    };
    _ = try parseInitializer(alloc, p, In, Yield, Await);
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
//
fn parseAssignmentExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseConditionalExpression(alloc, p, In, Yield, Await))) |_| return;
    if (Yield) if (w(parseYieldExpression(alloc, p, In, Await))) |_| return;
    if (w(parseArrowFunction(alloc, p, In, Yield, Await))) |_| return;
    if (w(parseAsyncArrowFunction(alloc, p, In, Yield, Await))) |_| return;

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idxi = p.idx;
        parseLeftHandSideExpression(alloc, p, Yield, Await) catch break;
        _ = blk: {
            if (w(p.eatTok("&&="))) |_| break :blk;
            if (w(p.eatTok("||="))) |_| break :blk;
            if (w(p.eatTok("??="))) |_| break :blk;
            if (w(parseAssignmentOperator(alloc, p))) |_| break :blk;
            if (w(p.eatTok("="))) |_| break :blk;
            p.idx = old_idxi;
            break;
        };
    }

    if (w(parseConditionalExpression(alloc, p, In, Yield, Await))) |_| return;
    if (Yield) if (w(parseYieldExpression(alloc, p, In, Await))) |_| return;
    if (w(parseArrowFunction(alloc, p, In, Yield, Await))) |_| return;
    if (w(parseAsyncArrowFunction(alloc, p, In, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// DoWhileStatement[Yield, Await, Return] : do Statement[?Yield, ?Await, ?Return] while ( Expression[+In, ?Yield, ?Await] ) ;
fn parseDoWhileStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("do");
    _ = try parseStatement(alloc, p, Yield, Await, Return);
    try p.eatTok("while");
    try p.eatTok("(");
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(")");
    try p.eatTok(";");
}

/// WhileStatement[Yield, Await, Return] : while ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
fn parseWhileStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("while");
    try p.eatTok("(");
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(")");
    _ = try parseStatement(alloc, p, Yield, Await, Return);
}

/// ForStatement[Yield, Await, Return] : for ( [lookahead ≠ let [] Expression[~In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
/// ForStatement[Yield, Await, Return] : for ( var VariableDeclarationList[~In, ?Yield, ?Await] ; Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
/// ForStatement[Yield, Await, Return] : for ( LexicalDeclaration[~In, ?Yield, ?Await] Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
fn parseForStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;

    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        parseLexicalDeclaration(alloc, p, false, Yield, Await) catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        p.eatTok("var") catch break :blk;
        parseVariableDeclarationList(alloc, p, false, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    return error.JsMalformed;
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
fn parseForInOfStatement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;

    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : for ( [lookahead ≠ let [] LeftHandSideExpression[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        _ = blk2: {
            p.eatTok("let") catch break :blk2;
            p.eatTok("[") catch break :blk;
            break :blk;
        };
        parseLeftHandSideExpression(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("in") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : for ( var ForBinding[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        p.eatTok("var") catch break :blk;
        parseForBinding(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("in") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : for ( ForDeclaration[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        parseForDeclaration(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("in") catch break :blk;
        parseExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : for ( [lookahead ∉ { let, async of }] LeftHandSideExpression[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        if (w(p.eatTok("let"))) |_| break :blk;
        _ = blk2: {
            p.eatTok("async") catch break :blk2;
            p.eatTok("of") catch break :blk;
            break :blk;
        };
        parseLeftHandSideExpression(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("of") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : for ( var ForBinding[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        p.eatTok("var") catch break :blk;
        parseForBinding(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("of") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : for ( ForDeclaration[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        p.eatTok("for") catch break :blk;
        p.eatTok("(") catch break :blk;
        parseForDeclaration(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("of") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : [+Await] for await ( [lookahead ≠ let] LeftHandSideExpression[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        if (!Await) break :blk;
        p.eatTok("for") catch break :blk;
        p.eatTok("await") catch break :blk;
        p.eatTok("(") catch break :blk;
        if (w(p.eatTok("let"))) |_| break :blk;
        parseLeftHandSideExpression(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("of") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : [+Await] for await ( var ForBinding[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        if (!Await) break :blk;
        p.eatTok("for") catch break :blk;
        p.eatTok("await") catch break :blk;
        p.eatTok("(") catch break :blk;
        p.eatTok("var") catch break :blk;
        parseForBinding(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("of") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ForInOfStatement[Yield, Await, Return] : [+Await] for await ( ForDeclaration[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
        if (!Await) break :blk;
        p.eatTok("for") catch break :blk;
        p.eatTok("await") catch break :blk;
        p.eatTok("(") catch break :blk;
        parseForDeclaration(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("of") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        p.eatTok(")") catch break :blk;
        parseStatement(alloc, p, Yield, Await, Return) catch break :blk;
        good = true;
        return;
    };
    return error.JsMalformed;
}

/// CaseBlock[Yield, Await, Return] : { CaseClauses[?Yield, ?Await, ?Return]? }
/// CaseBlock[Yield, Await, Return] : { CaseClauses[?Yield, ?Await, ?Return]? DefaultClause[?Yield, ?Await, ?Return] CaseClauses[?Yield, ?Await, ?Return]? }
fn parseCaseBlock(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("{");
    _ = try parseCaseClauses(alloc, p, Yield, Await, Return);
    if (w(p.eatTok("}"))) |_| return;
    _ = try parseDefaultClause(alloc, p, Yield, Await, Return);
    _ = try parseCaseClauses(alloc, p, Yield, Await, Return);
    try p.eatTok("}");
}

/// Identifier : IdentifierName but not ReservedWord
fn parseIdentifier(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatRange(0x21, 0x2F))) |_| return error.JsMalformed; // !  /
    if (w(p.eatRange(0x3A, 0x40))) |_| return error.JsMalformed; // :  @
    if (w(p.eatRange(0x5B, 0x60))) |_| return error.JsMalformed; // [  `
    if (w(p.eatRange(0x7B, 0x7E))) |_| return error.JsMalformed; // {  ~

    if (w(parseReservedWord(alloc, p))) |_| return error.JsMalformed;
    if (w(parseIdentifierName(alloc, p))) |_| {
        try p.eatSpace(true);
        return;
    }
    return error.JsMalformed;
}

/// CatchParameter[Yield, Await] : BindingIdentifier[?Yield, ?Await]
/// CatchParameter[Yield, Await] : BindingPattern[?Yield, ?Await]
fn parseCatchParameter(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseBindingIdentifier(alloc, p, Yield, Await))) |_| return;
    if (w(parseBindingPattern(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// FormalParameters[Yield, Await] : [empty]
/// FormalParameters[Yield, Await] : FunctionRestParameter[?Yield, ?Await]
/// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await]
/// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await] ,
/// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await] , FunctionRestParameter[?Yield, ?Await]
fn parseFormalParameters(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseFunctionRestParameter(alloc, p, Yield, Await))) |_| return;
    _ = parseFormalParameterList(alloc, p, Yield, Await) catch return;
    p.eatTok(",") catch return;
    _ = parseFunctionRestParameter(alloc, p, Yield, Await) catch return;
}

/// FunctionBody[Yield, Await] : FunctionStatementList[?Yield, ?Await]
fn parseFunctionBody(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseFunctionStatementList(alloc, p, Yield, Await);
}

/// GeneratorBody : FunctionBody[+Yield, ~Await]
fn parseGeneratorBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseFunctionBody(alloc, p, true, false);
}

/// AsyncFunctionBody : FunctionBody[~Yield, +Await]
fn parseAsyncFunctionBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseFunctionBody(alloc, p, false, true);
}

/// AsyncGeneratorBody : FunctionBody[+Yield, +Await]
fn parseAsyncGeneratorBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseFunctionBody(alloc, p, true, true);
}

/// ClassHeritage[Yield, Await] : extends LeftHandSideExpression[?Yield, ?Await]
fn parseClassHeritage(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("extends");
    _ = try parseLeftHandSideExpression(alloc, p, Yield, Await);
}

/// ClassBody[Yield, Await] : ClassElementList[?Yield, ?Await]
fn parseClassBody(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    return parseClassElementList(alloc, p, Yield, Await);
}

/// LexicalBinding[In, Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]?
/// LexicalBinding[In, Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]
fn parseLexicalBinding(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = parseBindingIdentifier(alloc, p, Yield, Await) catch {
        _ = try parseBindingPattern(alloc, p, Yield, Await);
        _ = try parseInitializer(alloc, p, In, Yield, Await);
        return;
    };
    _ = try parseInitializer(alloc, p, In, Yield, Await);
}

/// BindingPattern[Yield, Await] : ObjectBindingPattern[?Yield, ?Await]
/// BindingPattern[Yield, Await] : ArrayBindingPattern[?Yield, ?Await]
fn parseBindingPattern(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseObjectBindingPattern(alloc, p, Yield, Await))) |_| return;
    if (w(parseArrayBindingPattern(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// Initializer[In, Yield, Await] : = AssignmentExpression[?In, ?Yield, ?Await]
fn parseInitializer(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("=");
    _ = try parseAssignmentExpression(alloc, p, In, Yield, Await);
}

/// ConditionalExpression[In, Yield, Await] : ShortCircuitExpression[?In, ?Yield, ?Await]
/// ConditionalExpression[In, Yield, Await] : ShortCircuitExpression[?In, ?Yield, ?Await] ? AssignmentExpression[+In, ?Yield, ?Await] : AssignmentExpression[?In, ?Yield, ?Await]
fn parseConditionalExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseShortCircuitExpression(alloc, p, In, Yield, Await);
    p.eatTok("?") catch return;
    _ = try parseAssignmentExpression(alloc, p, true, Yield, Await);
    try p.eatTok(":");
    _ = try parseAssignmentExpression(alloc, p, In, Yield, Await);
}

/// YieldExpression[In, Await] : yield
/// YieldExpression[In, Await] : yield [no LineTerminator here] AssignmentExpression[?In, +Yield, ?Await]
/// YieldExpression[In, Await] : yield [no LineTerminator here] * AssignmentExpression[?In, +Yield, ?Await]
fn parseYieldExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("yield");
    try p.eatTok("*");
    _ = parseAssignmentExpression(alloc, p, In, true, Await) catch return;
}

/// ArrowFunction[In, Yield, Await] : ArrowParameters[?Yield, ?Await] [no LineTerminator here] => ConciseBody[?In]
fn parseArrowFunction(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseArrowParameters(alloc, p, Yield, Await);
    try p.eatTok("=>");
    _ = try parseConciseBody(alloc, p, In);
}

/// AsyncArrowFunction[In, Yield, Await] : async [no LineTerminator here] AsyncArrowBindingIdentifier[?Yield] [no LineTerminator here] => AsyncConciseBody[?In]
/// AsyncArrowFunction[In, Yield, Await] : CoverCallExpressionAndAsyncArrowHead[?Yield, ?Await] [no LineTerminator here] => AsyncConciseBody[?In]
fn parseAsyncArrowFunction(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = parseCoverCallExpressionAndAsyncArrowHead(alloc, p, Yield, Await, parseMemberExpression(alloc, p, Yield, Await) catch null) catch {
        try p.eatTok("async");
        _ = try parseAsyncArrowBindingIdentifier(alloc, p, Yield);
    };
    try p.eatTok("=>");
    _ = try parseAsyncConciseBody(alloc, p, In);
}

/// LeftHandSideExpression[Yield, Await] : NewExpression[?Yield, ?Await]
/// LeftHandSideExpression[Yield, Await] : CallExpression[?Yield, ?Await]
/// LeftHandSideExpression[Yield, Await] : OptionalExpression[?Yield, ?Await]
fn parseLeftHandSideExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    const member = parseMemberExpression(alloc, p, Yield, Await) catch null;
    if (w(parseCallExpression(alloc, p, Yield, Await, member))) |_| return;
    if (w(parseNewExpression(alloc, p, Yield, Await, member))) |_| return;
    if (w(parseOptionalExpression(alloc, p, Yield, Await, member))) |_| return;
    return error.JsMalformed;
}

///  AssignmentOperator : one of
/// *= /= %= += -= <<= >>= >>>= &= ^= |= **=
fn parseAssignmentOperator(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatTok(">>>="))) |_| return;
    if (w(p.eatTok(">>="))) |_| return;
    if (w(p.eatTok("<<="))) |_| return;
    if (w(p.eatTok("**="))) |_| return;
    if (w(p.eatTok("*="))) |_| return;
    if (w(p.eatTok("/="))) |_| return;
    if (w(p.eatTok("%="))) |_| return;
    if (w(p.eatTok("+="))) |_| return;
    if (w(p.eatTok("-="))) |_| return;
    if (w(p.eatTok("&="))) |_| return;
    if (w(p.eatTok("^="))) |_| return;
    if (w(p.eatTok("|="))) |_| return;
    return error.JsMalformed;
}

/// ForBinding[Yield, Await] : BindingIdentifier[?Yield, ?Await]
/// ForBinding[Yield, Await] : BindingPattern[?Yield, ?Await]
fn parseForBinding(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseBindingIdentifier(alloc, p, Yield, Await))) |_| return;
    if (w(parseBindingPattern(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// ForDeclaration[Yield, Await] : LetOrConst ForBinding[?Yield, ?Await]
fn parseForDeclaration(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseLetOrConst(alloc, p);
    _ = try parseForBinding(alloc, p, Yield, Await);
}

/// CaseClauses[Yield, Await, Return] : CaseClause[?Yield, ?Await, ?Return]
/// CaseClauses[Yield, Await, Return] : CaseClauses[?Yield, ?Await, ?Return] CaseClause[?Yield, ?Await, ?Return]
fn parseCaseClauses(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseCaseClause(alloc, p, Yield, Await, Return) catch if (i == 0) return error.JsMalformed else break;
    }
}

/// DefaultClause[Yield, Await, Return] : default : StatementList[?Yield, ?Await, ?Return]?
fn parseDefaultClause(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("default");
    try p.eatTok(":");
    _ = try parseStatementList(alloc, p, Yield, Await, Return);
}

/// IdentifierName :: IdentifierStart
/// IdentifierName :: IdentifierName IdentifierPart
fn parseIdentifierName(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseIdentifierStart(alloc, p);
    while (true) {
        _ = parseIdentifierPart(alloc, p) catch break;
    }
}

///  ReservedWord :: one of
/// await break case catch class const continue debugger default delete do else enum export extends false finally for function if import in instanceof new null return super switch this throw true try typeof var void while with yield
fn parseReservedWord(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eat("instanceof"))) |_| return;
    if (w(p.eat("continue"))) |_| return;
    if (w(p.eat("debugger"))) |_| return;
    if (w(p.eat("function"))) |_| return;
    if (w(p.eat("default"))) |_| return;
    if (w(p.eat("extends"))) |_| return;
    if (w(p.eat("finally"))) |_| return;
    if (w(p.eat("delete"))) |_| return;
    if (w(p.eat("export"))) |_| return;
    if (w(p.eat("import"))) |_| return;
    if (w(p.eat("return"))) |_| return;
    if (w(p.eat("switch"))) |_| return;
    if (w(p.eat("typeof"))) |_| return;
    if (w(p.eat("await"))) |_| return;
    if (w(p.eat("break"))) |_| return;
    if (w(p.eat("catch"))) |_| return;
    if (w(p.eat("class"))) |_| return;
    if (w(p.eat("const"))) |_| return;
    if (w(p.eat("false"))) |_| return;
    if (w(p.eat("super"))) |_| return;
    if (w(p.eat("throw"))) |_| return;
    if (w(p.eat("while"))) |_| return;
    if (w(p.eat("yield"))) |_| return;
    if (w(p.eat("case"))) |_| return;
    if (w(p.eat("else"))) |_| return;
    if (w(p.eat("enum"))) |_| return;
    if (w(p.eat("null"))) |_| return;
    if (w(p.eat("this"))) |_| return;
    if (w(p.eat("true"))) |_| return;
    if (w(p.eat("void"))) |_| return;
    if (w(p.eat("with"))) |_| return;
    if (w(p.eat("for"))) |_| return;
    if (w(p.eat("new"))) |_| return;
    if (w(p.eat("try"))) |_| return;
    if (w(p.eat("var"))) |_| return;
    if (w(p.eat("do"))) |_| return;
    if (w(p.eat("if"))) |_| return;
    if (w(p.eat("in"))) |_| return;
    return error.JsMalformed;
}

/// FunctionRestParameter[Yield, Await] : BindingRestElement[?Yield, ?Await]
fn parseFunctionRestParameter(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseBindingRestElement(alloc, p, Yield, Await);
}

/// FormalParameterList[Yield, Await] : FormalParameter[?Yield, ?Await]
/// FormalParameterList[Yield, Await] : FormalParameterList[?Yield, ?Await] , FormalParameter[?Yield, ?Await]
fn parseFormalParameterList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseFormalParameter(alloc, p, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// FunctionStatementList[Yield, Await] : StatementList[?Yield, ?Await, +Return]?
fn parseFunctionStatementList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    _ = parseStatementList(alloc, p, Yield, Await, true) catch null;
}

/// ClassElementList[Yield, Await] : ClassElement[?Yield, ?Await]
/// ClassElementList[Yield, Await] : ClassElementList[?Yield, ?Await] ClassElement[?Yield, ?Await]
fn parseClassElementList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseClassElement(alloc, p, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
    }
}

/// ObjectBindingPattern[Yield, Await] : { }
/// ObjectBindingPattern[Yield, Await] : { BindingRestProperty[?Yield, ?Await] }
/// ObjectBindingPattern[Yield, Await] : { BindingPropertyList[?Yield, ?Await] }
/// ObjectBindingPattern[Yield, Await] : { BindingPropertyList[?Yield, ?Await] , BindingRestProperty[?Yield, ?Await]? }
fn parseObjectBindingPattern(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("[");
    if (w(parseBindingPropertyList(alloc, p, Yield, Await))) |_| {
        p.eatTok(",") catch {};
        p.eatTok("]") catch return;
    }
    _ = parseBindingRestProperty(alloc, p, Yield, Await) catch {};
    try p.eatTok("]");
}

/// ArrayBindingPattern[Yield, Await] : [ Elision? BindingRestElement[?Yield, ?Await]? ]
/// ArrayBindingPattern[Yield, Await] : [ BindingElementList[?Yield, ?Await] ]
/// ArrayBindingPattern[Yield, Await] : [ BindingElementList[?Yield, ?Await] , Elision? BindingRestElement[?Yield, ?Await]? ]
fn parseArrayBindingPattern(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("[");
    if (w(parseBindingElementList(alloc, p, Yield, Await))) |_| {
        p.eatTok(",") catch {};
        p.eatTok("]") catch return;
    }
    parseElision(alloc, p) catch {};
    _ = parseBindingRestElement(alloc, p, Yield, Await) catch {};
    try p.eatTok("]");
}

/// ShortCircuitExpression[In, Yield, Await] : LogicalORExpression[?In, ?Yield, ?Await]
/// ShortCircuitExpression[In, Yield, Await] : CoalesceExpression[?In, ?Yield, ?Await]
fn parseShortCircuitExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    const bitwiseor = try parseBitwiseORExpression(alloc, p, In, Yield, Await);
    if (w(parseLogicalORExpression(alloc, p, In, Yield, Await, bitwiseor))) |_| return;
    if (w(parseCoalesceExpression(alloc, p, In, Yield, Await, bitwiseor))) |_| return;
    return error.JsMalformed;
}

/// ArrowParameters[Yield, Await] : BindingIdentifier[?Yield, ?Await]
/// ArrowParameters[Yield, Await] : CoverParenthesizedExpressionAndArrowParameterList[?Yield, ?Await]
fn parseArrowParameters(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseBindingIdentifier(alloc, p, Yield, Await))) |_| return;
    if (w(parseCoverParenthesizedExpressionAndArrowParameterList(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// ConciseBody[In] : [lookahead ≠ {] ExpressionBody[?In, ~Await]
/// ConciseBody[In] : { FunctionBody[~Yield, ~Await] }
fn parseConciseBody(alloc: std.mem.Allocator, p: *Parser, In: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatTok("{"))) |_| {
        _ = try parseFunctionBody(alloc, p, false, false);
        _ = try p.eatTok("}");
    }
    _ = try parseExpressionBody(alloc, p, In, false);
}

/// AsyncArrowBindingIdentifier[Yield] : BindingIdentifier[?Yield, +Await]
fn parseAsyncArrowBindingIdentifier(alloc: std.mem.Allocator, p: *Parser, Yield: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseBindingIdentifier(alloc, p, Yield, true);
}

/// CoverCallExpressionAndAsyncArrowHead[Yield, Await] : MemberExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
fn parseCoverCallExpressionAndAsyncArrowHead(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, _maybeMemberExpression: ?void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = _maybeMemberExpression orelse return error.JsMalformed;
    _ = try parseArguments(alloc, p, Yield, Await);
}

/// AsyncConciseBody[In] : [lookahead ≠ {] ExpressionBody[?In, +Await]
/// AsyncConciseBody[In] : { AsyncFunctionBody }
fn parseAsyncConciseBody(alloc: std.mem.Allocator, p: *Parser, In: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatTok("{"))) |_| {
        _ = try parseAsyncFunctionBody(alloc, p);
        try p.eatTok("}");
        return;
    }
    return parseExpressionBody(alloc, p, In, true);
}

/// NewExpression[Yield, Await] : MemberExpression[?Yield, ?Await]
/// NewExpression[Yield, Await] : new NewExpression[?Yield, ?Await]
fn parseNewExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, _maybeMemberExpression: ?void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    var n: usize = 0;
    while (w(p.eatTok("new"))) |_| : (n += 1) {
        //
    }
    if (n == 0) return _maybeMemberExpression orelse error.JsMalformed;
    return parseMemberExpression(alloc, p, Yield, Await);
}

/// CallExpression[Yield, Await] : CoverCallExpressionAndAsyncArrowHead[?Yield, ?Await]
/// CallExpression[Yield, Await] : SuperCall[?Yield, ?Await]
/// CallExpression[Yield, Await] : ImportCall[?Yield, ?Await]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . IdentifierName
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
/// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . PrivateIdentifier
fn parseCallExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, _maybeMemberExpression: ?void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    _ = blk: {
        if (w(parseSuperCall(alloc, p, Yield, Await))) |_| break :blk;
        if (w(parseImportCall(alloc, p, Yield, Await))) |_| break :blk;
        if (w(parseCoverCallExpressionAndAsyncArrowHead(alloc, p, Yield, Await, _maybeMemberExpression))) |_| break :blk;
        return error.JsMalformed;
    };

    var i: usize = 0;
    while (true) : (i += 1) {
        _ = blk: {
            var old_idx = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idx;
            };
            // CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
            parseArguments(alloc, p, Yield, Await) catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idx = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idx;
            };
            // CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
            p.eatTok("[") catch break :blk;
            parseExpression(alloc, p, true, Yield, Await) catch break :blk;
            p.eatTok("]") catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idx = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idx;
            };
            // CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . IdentifierName
            p.eatTok(".") catch break :blk;
            parseIdentifierName(alloc, p) catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idx = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idx;
            };
            // CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
            parseTemplateLiteral(alloc, p, Yield, Await, true) catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idx = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idx;
            };
            // CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . PrivateIdentifier
            p.eatTok(".") catch break :blk;
            parsePrivateIdentifier(alloc, p) catch break :blk;
            good = true;
            continue;
        };
        break;
    }
}

/// OptionalExpression[Yield, Await] : MemberExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
/// OptionalExpression[Yield, Await] : CallExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
/// OptionalExpression[Yield, Await] : OptionalExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
fn parseOptionalExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, _maybeMemberExpression: ?void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = blk: {
        if (w(parseCallExpression(alloc, p, Yield, Await, _maybeMemberExpression))) |_| break :blk;
        if (_maybeMemberExpression) |_| break :blk;
        return error.JsMalformed;
    };
    var i: usize = 0;
    while (true) : (i += 1) {
        _ = parseOptionalChain(alloc, p, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
    }
}

/// CaseClause[Yield, Await, Return] : case Expression[+In, ?Yield, ?Await] : StatementList[?Yield, ?Await, ?Return]?
fn parseCaseClause(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Return: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("case");
    _ = try parseExpression(alloc, p, true, Yield, Await);
    try p.eatTok(":");
    _ = try parseStatementList(alloc, p, Yield, Await, Return);
}

/// IdentifierStart :: IdentifierStartChar
/// IdentifierStart :: \ UnicodeEscapeSequence
fn parseIdentifierStart(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eat("\\"))) |_| {
        _ = try parseUnicodeEscapeSequence(alloc, p);
        return;
    }
    _ = try parseIdentifierStartChar(alloc, p);
}

/// IdentifierPart :: IdentifierPartChar
/// IdentifierPart :: \ UnicodeEscapeSequence
fn parseIdentifierPart(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eat("\\"))) |_| {
        _ = try parseUnicodeEscapeSequence(alloc, p);
        return;
    }
    _ = try parseIdentifierPartChar(alloc, p);
}

/// BindingRestElement[Yield, Await] : ... BindingIdentifier[?Yield, ?Await]
/// BindingRestElement[Yield, Await] : ... BindingPattern[?Yield, ?Await]
fn parseBindingRestElement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("...");
    if (w(parseBindingIdentifier(alloc, p, Yield, Await))) |_| return;
    if (w(parseBindingPattern(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// FormalParameter[Yield, Await] : BindingElement[?Yield, ?Await]
fn parseFormalParameter(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseBindingElement(alloc, p, Yield, Await);
}

/// ClassElement[Yield, Await] : MethodDefinition[?Yield, ?Await]
/// ClassElement[Yield, Await] : static MethodDefinition[?Yield, ?Await]
/// ClassElement[Yield, Await] : FieldDefinition[?Yield, ?Await] ;
/// ClassElement[Yield, Await] : static FieldDefinition[?Yield, ?Await] ;
/// ClassElement[Yield, Await] : ClassStaticBlock
/// ClassElement[Yield, Await] : ;
fn parseClassElement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;

    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        parseMethodDefinition(alloc, p, Yield, Await) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eatTok("static") catch break :blk;
        parseMethodDefinition(alloc, p, Yield, Await) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        parseFieldDefinition(alloc, p, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eatTok("static") catch break :blk;
        parseFieldDefinition(alloc, p, Yield, Await) catch break :blk;
        p.eatTok(";") catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        parseClassStaticBlock(alloc, p) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eatTok(";") catch break :blk;
        good = true;
        return;
    };
    return error.JsMalformed;
}

/// BindingRestProperty[Yield, Await] : ... BindingIdentifier[?Yield, ?Await]
fn parseBindingRestProperty(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("...");
    return try parseBindingIdentifier(alloc, p, Yield, Await);
}

/// BindingPropertyList[Yield, Await] : BindingProperty[?Yield, ?Await]
/// BindingPropertyList[Yield, Await] : BindingPropertyList[?Yield, ?Await] , BindingProperty[?Yield, ?Await]
fn parseBindingPropertyList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseBindingProperty(alloc, p, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// Elision : ,
/// Elision : Elision ,
fn parseElision(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    _ = alloc;
    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        p.eatTok(",") catch if (i == 0) return error.JsMalformed else break;
    }
}

/// BindingElementList[Yield, Await] : BindingElisionElement[?Yield, ?Await]
/// BindingElementList[Yield, Await] : BindingElementList[?Yield, ?Await] , BindingElisionElement[?Yield, ?Await]
fn parseBindingElementList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseBindingElisionElement(alloc, p, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// LogicalORExpression[In, Yield, Await] : LogicalANDExpression[?In, ?Yield, ?Await]
/// LogicalORExpression[In, Yield, Await] : LogicalORExpression[?In, ?Yield, ?Await] || LogicalANDExpression[?In, ?Yield, ?Await]
fn parseLogicalORExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool, _firstBitwiseORExpression: void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        if (i == 0) {
            _ = parseLogicalANDExpression(alloc, p, In, Yield, Await, _firstBitwiseORExpression) catch return error.JsMalformed;
        } else {
            _ = parseLogicalANDExpression(alloc, p, In, Yield, Await, null) catch break;
        }
        p.eatTok("||") catch break;
    }
}

/// CoalesceExpression[In, Yield, Await] : CoalesceExpressionHead[?In, ?Yield, ?Await] ?? BitwiseORExpression[?In, ?Yield, ?Await]
/// CoalesceExpressionHead[In, Yield, Await] : CoalesceExpression[?In, ?Yield, ?Await]
/// CoalesceExpressionHead[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await]
fn parseCoalesceExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool, _firstBitwiseORExpression: void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    _ = _firstBitwiseORExpression;
    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        p.eatTok("??") catch break;
        _ = parseBitwiseORExpression(alloc, p, In, Yield, Await) catch break;
    }
}

/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( ... BindingIdentifier[?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( ... BindingPattern[?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , ... BindingIdentifier[?Yield, ?Await] )
/// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , ... BindingPattern[?Yield, ?Await] )
fn parseCoverParenthesizedExpressionAndArrowParameterList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("(");
    if (w(p.eatTok(")"))) |_| return;

    if (w(p.eatTok("..."))) |_| {
        if (w(parseBindingIdentifier(alloc, p, Yield, Await))) |_| return;
        if (w(parseBindingPattern(alloc, p, Yield, Await))) |_| return;
        if (w(p.eatTok(")"))) |_| return;
        return error.JsMalformed;
    }

    try parseExpression(alloc, p, true, Yield, Await);
    if (w(p.eatTok(")"))) |_| return;

    try p.eatTok(",");
    if (w(p.eatTok(")"))) |_| return;

    if (w(p.eatTok("..."))) |_| {
        if (w(parseBindingIdentifier(alloc, p, Yield, Await))) |_| return;
        if (w(parseBindingPattern(alloc, p, Yield, Await))) |_| return;
        if (w(p.eatTok(")"))) |_| return;
        return error.JsMalformed;
    }
    return error.JsMalformed;
}

/// ExpressionBody[In, Await] : AssignmentExpression[?In, ~Yield, ?Await]
fn parseExpressionBody(alloc: std.mem.Allocator, p: *Parser, In: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseAssignmentExpression(alloc, p, In, false, Await);
}

/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . IdentifierName
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
/// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . PrivateIdentifier
fn parseMemberExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try parseMemberExpressionInner(alloc, p, Yield, Await);

    var i: usize = 0;
    while (true) : (i += 1) {
        _ = blk: {
            var old_idxi = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idxi;
            };
            // MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
            p.eatTok("[") catch break :blk;
            parseExpression(alloc, p, true, Yield, Await) catch break :blk;
            p.eatTok("]") catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idxi = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idxi;
            };
            // MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . IdentifierName
            p.eatTok(".") catch break :blk;
            parseIdentifierName(alloc, p) catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idxi = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idxi;
            };
            // MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
            parseTemplateLiteral(alloc, p, Yield, Await, true) catch break :blk;
            good = true;
            continue;
        };
        _ = blk: {
            var old_idxi = p.idx;
            var good = false;
            defer if (!good) {
                p.idx = old_idxi;
            };
            // MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . PrivateIdentifier
            p.eatTok(".") catch break :blk;
            parsePrivateIdentifier(alloc, p) catch break :blk;
            good = true;
            continue;
        };
        break;
    }
}
/// MemberExpression[Yield, Await] : PrimaryExpression[?Yield, ?Await]
/// MemberExpression[Yield, Await] : SuperProperty[?Yield, ?Await]
/// MemberExpression[Yield, Await] : MetaProperty
/// MemberExpression[Yield, Await] : new MemberExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
fn parseMemberExpressionInner(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parsePrimaryExpression(alloc, p, Yield, Await))) |_| return;
    if (w(parseSuperProperty(alloc, p, Yield, Await))) |_| return;
    if (w(parseMetaProperty(alloc, p))) |_| return;

    try p.eatTok("new");
    try parseMemberExpression(alloc, p, Yield, Await);
    try parseArguments(alloc, p, Yield, Await);
}

/// Arguments[Yield, Await] : ( )
/// Arguments[Yield, Await] : ( ArgumentList[?Yield, ?Await] )
/// Arguments[Yield, Await] : ( ArgumentList[?Yield, ?Await] , )
fn parseArguments(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("(");
    parseArgumentList(alloc, p, Yield, Await) catch {};
    p.eatTok(",") catch {};
    try p.eatTok(")");
}

/// SuperCall[Yield, Await] : super Arguments[?Yield, ?Await]
fn parseSuperCall(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("super");
    _ = try parseArguments(alloc, p, Yield, Await);
}

/// ImportCall[Yield, Await] : import ( AssignmentExpression[+In, ?Yield, ?Await] )
fn parseImportCall(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("import");
    try p.eatTok("(");
    _ = try parseAssignmentExpression(alloc, p, true, Yield, Await);
    try p.eatTok(")");
}

/// TemplateLiteral[Yield, Await, Tagged] : NoSubstitutionTemplate
/// TemplateLiteral[Yield, Await, Tagged] : SubstitutionTemplate[?Yield, ?Await, ?Tagged]
fn parseTemplateLiteral(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Tagged: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseNoSubstitutionTemplate(alloc, p))) |_| return;
    if (w(parseSubstitutionTemplate(alloc, p, Yield, Await, Tagged))) |_| return;
    return error.JsMalformed;
}

/// PrivateIdentifier :: # IdentifierName
fn parsePrivateIdentifier(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("#");
    return parseIdentifierName(alloc, p);
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
fn parseOptionalChain(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    //TODO:
    _ = alloc;
    _ = Yield;
    _ = Await;
    _ = &parseArguments;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parsePrivateIdentifier;
    _ = &parseLeftHandSideExpression;
    _ = &parseCallExpression;
    _ = &parseNewExpression;
    _ = &parseOptionalExpression;
    return error.TODO;
}

/// IdentifierStartChar :: UnicodeIDStart
/// IdentifierStartChar :: $
/// IdentifierStartChar :: _
fn parseIdentifierStartChar(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatByte('$'))) |_| return;
    if (w(p.eatByte('_'))) |_| return;
    if (w(parseUnicodeIDStart(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// UnicodeEscapeSequence :: u Hex4Digits
/// UnicodeEscapeSequence :: u{ CodePoint }
fn parseUnicodeEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eat("u{"))) |_| {
        _ = try parseCodePoint(alloc, p);
        try p.eat("}");
        return;
    }
    try p.eat("u");
    _ = try parseHex4Digits(alloc, p);
}

/// IdentifierPartChar :: UnicodeIDContinue
/// IdentifierPartChar :: $
/// IdentifierPartChar :: <ZWNJ>
/// IdentifierPartChar :: <ZWJ>
fn parseIdentifierPartChar(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatByte('$'))) |_| return;
    if (w(p.eatCp(0x200C))) |_| return; // <ZWNJ>
    if (w(p.eatCp(0x200D))) |_| return; // <ZWJ>
    if (w(parseUnicodeIDContinue(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// BindingElement[Yield, Await] : SingleNameBinding[?Yield, ?Await]
/// BindingElement[Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseBindingElement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseSingleNameBinding(alloc, p, Yield, Await))) |_| return;

    _ = try parseBindingPattern(alloc, p, Yield, Await);
    _ = try parseInitializer(alloc, p, true, Yield, Await);
}

/// MethodDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
/// MethodDefinition[Yield, Await] : GeneratorMethod[?Yield, ?Await]
/// MethodDefinition[Yield, Await] : AsyncMethod[?Yield, ?Await]
/// MethodDefinition[Yield, Await] : AsyncGeneratorMethod[?Yield, ?Await]
/// MethodDefinition[Yield, Await] : get ClassElementName[?Yield, ?Await] ( ) { FunctionBody[~Yield, ~Await] }
/// MethodDefinition[Yield, Await] : set ClassElementName[?Yield, ?Await] ( PropertySetParameterList ) { FunctionBody[~Yield, ~Await] }
fn parseMethodDefinition(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseGeneratorMethod(alloc, p, Yield, Await))) |_| return;
    if (w(parseAsyncMethod(alloc, p, Yield, Await))) |_| return;
    if (w(parseAsyncGeneratorMethod(alloc, p, Yield, Await))) |_| return;

    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // MethodDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
        parseClassElementName(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("(") catch break :blk;
        parseUniqueFormalParameters(alloc, p, false, false) catch break :blk;
        p.eatTok(")") catch break :blk;
        p.eatTok("{") catch break :blk;
        parseFunctionBody(alloc, p, false, false) catch break :blk;
        p.eatTok("}") catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // MethodDefinition[Yield, Await] : get ClassElementName[?Yield, ?Await] ( ) { FunctionBody[~Yield, ~Await] }
        p.eatTok("get") catch break :blk;
        parseClassElementName(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("(") catch break :blk;
        p.eatTok(")") catch break :blk;
        p.eatTok("{") catch break :blk;
        parseFunctionBody(alloc, p, false, false) catch break :blk;
        p.eatTok("}") catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // MethodDefinition[Yield, Await] : set ClassElementName[?Yield, ?Await] ( PropertySetParameterList ) { FunctionBody[~Yield, ~Await] }
        p.eatTok("set") catch break :blk;
        parseClassElementName(alloc, p, Yield, Await) catch break :blk;
        p.eatTok("(") catch break :blk;
        parsePropertySetParameterList(alloc, p) catch break :blk;
        p.eatTok(")") catch break :blk;
        p.eatTok("{") catch break :blk;
        parseFunctionBody(alloc, p, false, false) catch break :blk;
        p.eatTok("}") catch break :blk;
        good = true;
        return;
    };
    return error.JsMalformed;
}

/// FieldDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseFieldDefinition(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseClassElementName(alloc, p, Yield, Await);
    _ = try parseInitializer(alloc, p, true, Yield, Await);
}

/// ClassStaticBlock : static { ClassStaticBlockBody }
fn parseClassStaticBlock(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("static");
    try p.eatTok("{");
    _ = try parseClassStaticBlockBody(alloc, p);
    try p.eatTok("}");
}

/// BindingProperty[Yield, Await] : SingleNameBinding[?Yield, ?Await]
/// BindingProperty[Yield, Await] : PropertyName[?Yield, ?Await] : BindingElement[?Yield, ?Await]
fn parseBindingProperty(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseSingleNameBinding(alloc, p, Yield, Await))) |_| return;

    _ = try parsePropertyName(alloc, p, Yield, Await);
    try p.eatTok(":");
    _ = try parseBindingElement(alloc, p, Yield, Await);
}

/// BindingElisionElement[Yield, Await] : Elision? BindingElement[?Yield, ?Await]
fn parseBindingElisionElement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    parseElision(alloc, p) catch {};
    _ = try parseBindingElement(alloc, p, Yield, Await);
}

/// LogicalANDExpression[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await]
/// LogicalANDExpression[In, Yield, Await] : LogicalANDExpression[?In, ?Yield, ?Await] && BitwiseORExpression[?In, ?Yield, ?Await]
fn parseLogicalANDExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool, _maybeBitwiseORExpression: ?void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        if (i == 0) {
            _ = _maybeBitwiseORExpression orelse return error.JsMalformed;
        } else {
            _ = parseBitwiseORExpression(alloc, p, In, Yield, Await) catch break;
        }
        p.eatTok("&&") catch break;
    }
}

/// BitwiseORExpression[In, Yield, Await] : BitwiseXORExpression[?In, ?Yield, ?Await]
/// BitwiseORExpression[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await] | BitwiseXORExpression[?In, ?Yield, ?Await]
fn parseBitwiseORExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseBitwiseXORExpression(alloc, p, In, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok("|") catch break;
    }
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
fn parsePrimaryExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatTok("this"))) |_| return;
    if (w(parseIdentifierReference(alloc, p, Yield, Await))) |_| return;
    if (w(parseLiteral(alloc, p))) |_| return;
    if (w(parseArrayLiteral(alloc, p, Yield, Await))) |_| return;
    if (w(parseObjectLiteral(alloc, p, Yield, Await))) |_| return;
    if (w(parseFunctionExpression(alloc, p))) |_| return;
    if (w(parseClassExpression(alloc, p, Yield, Await))) |_| return;
    if (w(parseGeneratorExpression(alloc, p))) |_| return;
    if (w(parseAsyncFunctionExpression(alloc, p))) |_| return;
    if (w(parseAsyncGeneratorExpression(alloc, p))) |_| return;
    if (w(parseRegularExpressionLiteral(alloc, p))) |_| return;
    if (w(parseTemplateLiteral(alloc, p, Yield, Await, false))) |_| return;
    if (w(parseCoverParenthesizedExpressionAndArrowParameterList(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// SuperProperty[Yield, Await] : super [ Expression[+In, ?Yield, ?Await] ]
/// SuperProperty[Yield, Await] : super . IdentifierName
fn parseSuperProperty(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("super");
    if (w(p.eatTok("["))) |_| {
        _ = try parseExpression(alloc, p, true, Yield, Await);
        try p.eatTok("]");
        return;
    }
    try p.eatTok(".");
    _ = try parseIdentifierName(alloc, p);
}

/// MetaProperty : NewTarget
/// MetaProperty : ImportMeta
fn parseMetaProperty(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseNewTarget(alloc, p))) |_| return;
    if (w(parseImportMeta(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// ArgumentList[Yield, Await] : AssignmentExpression[+In, ?Yield, ?Await]
/// ArgumentList[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
/// ArgumentList[Yield, Await] : ArgumentList[?Yield, ?Await] , AssignmentExpression[+In, ?Yield, ?Await]
/// ArgumentList[Yield, Await] : ArgumentList[?Yield, ?Await] , ... AssignmentExpression[+In, ?Yield, ?Await]
fn parseArgumentList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        p.eatTok("...") catch {};
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// NoSubstitutionTemplate :: ` TemplateCharacters? `
fn parseNoSubstitutionTemplate(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("`");
    _ = try parseTemplateCharacters(alloc, p);
    try p.eat("`");
}

/// SubstitutionTemplate[Yield, Await, Tagged] : TemplateHead Expression[+In, ?Yield, ?Await] TemplateSpans[?Yield, ?Await, ?Tagged]
fn parseSubstitutionTemplate(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Tagged: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseTemplateHead(alloc, p);
    _ = try parseExpression(alloc, p, true, Yield, Await);
    _ = try parseTemplateSpans(alloc, p, Yield, Await, Tagged);
}

///  UnicodeIDStart ::
/// any Unicode code point with the Unicode property “ID_Start”
fn parseUnicodeIDStart(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    @setEvalBranchQuota(100_000);
    inline for (unicodeucd.derived_core_properties.data) |item| {
        if (item.prop == .ID_Start) {
            if (w(p.eatRangeM(item.from, item.to))) |_| return;
        }
    }
    return error.JsMalformed;
}

/// Hex4Digits :: HexDigit HexDigit HexDigit HexDigit
fn parseHex4Digits(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseHexDigit(alloc, p);
    _ = try parseHexDigit(alloc, p);
    _ = try parseHexDigit(alloc, p);
    _ = try parseHexDigit(alloc, p);
}

///  CodePoint ::
/// HexDigits[~Sep] but only if MV of HexDigits ≤ 0x10FFFF
fn parseCodePoint(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    //TODO:
    _ = alloc;
    return error.TODO;
}

///  UnicodeIDContinue ::
/// any Unicode code point with the Unicode property “ID_Continue”
fn parseUnicodeIDContinue(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    @setEvalBranchQuota(100_000);
    inline for (unicodeucd.derived_core_properties.data) |item| {
        if (item.prop == .ID_Continue) {
            if (w(p.eatRangeM(item.from, item.to))) |_| return;
        }
    }
    return error.JsMalformed;
}

/// SingleNameBinding[Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseSingleNameBinding(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseBindingIdentifier(alloc, p, Yield, Await);
    _ = try parseInitializer(alloc, p, true, Yield, Await);
}

/// ClassElementName[Yield, Await] : PropertyName[?Yield, ?Await]
/// ClassElementName[Yield, Await] : PrivateIdentifier
fn parseClassElementName(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parsePrivateIdentifier(alloc, p))) |_| return;
    if (w(parsePropertyName(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// UniqueFormalParameters[Yield, Await] : FormalParameters[?Yield, ?Await]
fn parseUniqueFormalParameters(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseFormalParameters(alloc, p, Yield, Await);
}

/// GeneratorMethod[Yield, Await] : * ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorMethod(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("*");
    _ = try parseClassElementName(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseUniqueFormalParameters(alloc, p, true, false);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseGeneratorBody(alloc, p);
    try p.eatTok("}");
}

/// AsyncMethod[Yield, Await] : async [no LineTerminator here] ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncMethod(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("async");
    _ = try parseClassElementName(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseUniqueFormalParameters(alloc, p, false, true);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseAsyncFunctionBody(alloc, p);
    try p.eatTok("}");
}

/// AsyncGeneratorMethod[Yield, Await] : async [no LineTerminator here] * ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorMethod(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("async");
    try p.eatTok("*");
    _ = try parseClassElementName(alloc, p, Yield, Await);
    try p.eatTok("(");
    _ = try parseUniqueFormalParameters(alloc, p, true, true);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseAsyncGeneratorBody(alloc, p);
    try p.eatTok("}");
}

/// PropertySetParameterList : FormalParameter[~Yield, ~Await]
fn parsePropertySetParameterList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseFormalParameter(alloc, p, false, false);
}

/// ClassStaticBlockBody : ClassStaticBlockStatementList
fn parseClassStaticBlockBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseClassStaticBlockStatementList(alloc, p);
}

/// PropertyName[Yield, Await] : LiteralPropertyName
/// PropertyName[Yield, Await] : ComputedPropertyName[?Yield, ?Await]
fn parsePropertyName(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseLiteralPropertyName(alloc, p))) |_| return;
    if (w(parseComputedPropertyName(alloc, p, Yield, Await))) |_| return;
    return error.JsMalformed;
}

/// BitwiseXORExpression[In, Yield, Await] : BitwiseANDExpression[?In, ?Yield, ?Await]
/// BitwiseXORExpression[In, Yield, Await] : BitwiseXORExpression[?In, ?Yield, ?Await] ^ BitwiseANDExpression[?In, ?Yield, ?Await]
fn parseBitwiseXORExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseBitwiseANDExpression(alloc, p, In, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok("^") catch break;
    }
}

/// IdentifierReference[Yield, Await] : Identifier
/// IdentifierReference[Yield, Await] : [~Yield] yield
/// IdentifierReference[Yield, Await] : [~Await] await
fn parseIdentifierReference(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (!Yield) if (w(p.eatTok("yield"))) |_| return;
    if (!Await) if (w(p.eatTok("await"))) |_| return;
    if (w(parseIdentifier(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// Literal : NullLiteral
/// Literal : BooleanLiteral
/// Literal : NumericLiteral
/// Literal : StringLiteral
fn parseLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseNullLiteral(alloc, p))) |_| return;
    if (w(parseBooleanLiteral(alloc, p))) |_| return;
    if (w(parseNumericLiteral(alloc, p))) |_| return;
    if (w(parseStringLiteral(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// ArrayLiteral[Yield, Await] : [ Elision? ]
/// ArrayLiteral[Yield, Await] : [ ElementList[?Yield, ?Await] ]
/// ArrayLiteral[Yield, Await] : [ ElementList[?Yield, ?Await] , Elision? ]
fn parseArrayLiteral(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("[");

    parseElision(alloc, p) catch {};
    if (w(p.eatTok("]"))) |_| return;

    _ = try parseElementList(alloc, p, Yield, Await);
    if (w(p.eatTok("]"))) |_| return;

    try parseElision(alloc, p);
    try p.eatTok("]");
}

/// ObjectLiteral[Yield, Await] : { }
/// ObjectLiteral[Yield, Await] : { PropertyDefinitionList[?Yield, ?Await] }
/// ObjectLiteral[Yield, Await] : { PropertyDefinitionList[?Yield, ?Await] , }
fn parseObjectLiteral(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("{");
    if (w(p.eatTok("}"))) |_| return;
    _ = try parsePropertyDefinitionList(alloc, p, Yield, Await);
    if (w(p.eatTok("}"))) |_| return;
    try p.eatTok(",");
    try p.eatTok("}");
}

/// FunctionExpression : function BindingIdentifier[~Yield, ~Await]? ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
fn parseFunctionExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("function");
    _ = try parseBindingIdentifier(alloc, p, false, false);
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, false, false);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseFunctionBody(alloc, p, false, false);
    try p.eatTok("}");
}

/// ClassExpression[Yield, Await] : class BindingIdentifier[?Yield, ?Await]? ClassTail[?Yield, ?Await]
fn parseClassExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("class");
    _ = parseBindingIdentifier(alloc, p, Yield, Await) catch null;
    _ = try parseClassTail(alloc, p, Yield, Await);
}

/// GeneratorExpression : function * BindingIdentifier[+Yield, ~Await]? ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("function");
    try p.eatTok("*");
    _ = parseBindingIdentifier(alloc, p, true, false) catch null;
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, true, false);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseGeneratorBody(alloc, p);
    try p.eatTok("}");
}

/// AsyncFunctionExpression : async [no LineTerminator here] function BindingIdentifier[~Yield, +Await]? ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncFunctionExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("async");
    try p.eatTok("function");
    try p.eatTok("*");
    _ = parseBindingIdentifier(alloc, p, false, true) catch null;
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, false, true);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseAsyncFunctionBody(alloc, p);
    try p.eatTok("}");
}

/// AsyncGeneratorExpression : async [no LineTerminator here] function * BindingIdentifier[+Yield, +Await]? ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorExpression(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("async");
    try p.eatTok("function");
    try p.eatTok("*");
    _ = parseBindingIdentifier(alloc, p, true, true) catch null;
    try p.eatTok("(");
    _ = try parseFormalParameters(alloc, p, true, true);
    try p.eatTok(")");
    try p.eatTok("{");
    _ = try parseAsyncGeneratorBody(alloc, p);
    try p.eatTok("}");
}

/// RegularExpressionLiteral :: / RegularExpressionBody / RegularExpressionFlags
fn parseRegularExpressionLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("/");
    _ = try parseRegularExpressionBody(alloc, p);
    try p.eat("/");
    _ = try parseRegularExpressionFlags(alloc, p);
}

/// NewTarget : new . target
fn parseNewTarget(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    try p.eatTok("new");
    try p.eatTok(".");
    try p.eatTok("target");
}

/// ImportMeta : import . meta
fn parseImportMeta(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    try p.eatTok("import");
    try p.eatTok(".");
    try p.eatTok("meta");
}

/// TemplateCharacters :: TemplateCharacter TemplateCharacters?
fn parseTemplateCharacters(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseTemplateCharacter(alloc, p) catch if (i == 0) return error.JsMalformed else break;
    }
}

/// TemplateHead :: ` TemplateCharacters? ${
fn parseTemplateHead(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("`");
    _ = try parseTemplateCharacters(alloc, p);
    try p.eat("${");
}

/// TemplateSpans[Yield, Await, Tagged] : TemplateTail
/// TemplateSpans[Yield, Await, Tagged] : TemplateMiddleList[?Yield, ?Await, ?Tagged] TemplateTail
fn parseTemplateSpans(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Tagged: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = parseTemplateMiddleList(alloc, p, Yield, Await, Tagged) catch {};
    _ = try parseTemplateTail(alloc, p);
}

///  HexDigit :: one of
/// 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F
fn parseHexDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatRange('0', '9'))) |_| return;
    if (w(p.eatRange('a', 'f'))) |_| return;
    if (w(p.eatRange('A', 'F'))) |_| return;
    return error.JsMalformed;
}

/// ClassStaticBlockStatementList : StatementList[~Yield, +Await, ~Return]?
fn parseClassStaticBlockStatementList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseStatementList(alloc, p, false, true, false);
}

/// LiteralPropertyName : IdentifierName
/// LiteralPropertyName : StringLiteral
/// LiteralPropertyName : NumericLiteral
fn parseLiteralPropertyName(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseIdentifierName(alloc, p))) |_| return;
    if (w(parseStringLiteral(alloc, p))) |_| return;
    if (w(parseNumericLiteral(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// ComputedPropertyName[Yield, Await] : [ AssignmentExpression[+In, ?Yield, ?Await] ]
fn parseComputedPropertyName(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("[");
    _ = try parseAssignmentExpression(alloc, p, true, Yield, Await);
    try p.eatTok("]");
}

/// BitwiseANDExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await]
/// BitwiseANDExpression[In, Yield, Await] : BitwiseANDExpression[?In, ?Yield, ?Await] & EqualityExpression[?In, ?Yield, ?Await]
fn parseBitwiseANDExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseEqualityExpression(alloc, p, In, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok("&") catch break;
    }
}

/// NullLiteral :: null
fn parseNullLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    _ = alloc;
    return p.eat("null");
}

/// BooleanLiteral :: true
/// BooleanLiteral :: false
fn parseBooleanLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eat("true"))) |_| return;
    if (w(p.eat("false"))) |_| return;
    return error.JsMalformed;
}

/// NumericLiteral :: DecimalLiteral
/// NumericLiteral :: DecimalBigIntegerLiteral
/// NumericLiteral :: NonDecimalIntegerLiteral[+Sep]
/// NumericLiteral :: NonDecimalIntegerLiteral[+Sep] BigIntLiteralSuffix
/// NumericLiteral :: LegacyOctalIntegerLiteral
fn parseNumericLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseDecimalLiteral(alloc, p))) |_| return;
    if (w(parseDecimalBigIntegerLiteral(alloc, p))) |_| return;
    _ = try parseNonDecimalIntegerLiteral(alloc, p, true);
    parseBigIntLiteralSuffix(alloc, p) catch return;
}

/// StringLiteral :: " DoubleStringCharacter* "
/// StringLiteral :: ' SingleStringCharacter* '
fn parseStringLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    const q = try p.eatAny(&.{ '"', '\'' });
    while (true) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        switch (q) {
            0x22 => _ = parseDoubleStringCharacter(alloc, p) catch break,
            0x27 => _ = parseSingleStringCharacter(alloc, p) catch break,
            else => unreachable,
        }
    }
    _ = try p.eatByte(q);
}

/// ElementList[Yield, Await] : Elision? AssignmentExpression[+In, ?Yield, ?Await]
/// ElementList[Yield, Await] : Elision? SpreadElement[?Yield, ?Await]
/// ElementList[Yield, Await] : ElementList[?Yield, ?Await] , Elision? AssignmentExpression[+In, ?Yield, ?Await]
/// ElementList[Yield, Await] : ElementList[?Yield, ?Await] , Elision? SpreadElement[?Yield, ?Await]
//
fn parseElementList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        parseElision(alloc, p) catch {};
        if (w(parseAssignmentExpression(alloc, p, true, Yield, Await))) |_| continue;
        if (w(parseSpreadElement(alloc, p, Yield, Await))) |_| continue;
        if (i == 0) return error.JsMalformed else break;
    }
}

/// PropertyDefinitionList[Yield, Await] : PropertyDefinition[?Yield, ?Await]
/// PropertyDefinitionList[Yield, Await] : PropertyDefinitionList[?Yield, ?Await] , PropertyDefinition[?Yield, ?Await]
fn parsePropertyDefinitionList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parsePropertyDefinition(alloc, p, Yield, Await) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// RegularExpressionBody :: RegularExpressionFirstChar RegularExpressionChar*
fn parseRegularExpressionBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseRegularExpressionFirstChar(alloc, p);
    while (true) {
        var old_idx2 = p.idx;
        errdefer p.idx = old_idx2;

        _ = parseRegularExpressionChar(alloc, p) catch break;
    }
}

/// RegularExpressionFlags :: [empty]
/// RegularExpressionFlags :: RegularExpressionFlags IdentifierPartChar
fn parseRegularExpressionFlags(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    while (true) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseIdentifierPartChar(alloc, p) catch break;
    }
}

/// TemplateCharacter :: $ [lookahead ≠ {]
/// TemplateCharacter :: \ TemplateEscapeSequence
/// TemplateCharacter :: \ NotEscapeSequence
/// TemplateCharacter :: LineContinuation
/// TemplateCharacter :: LineTerminatorSequence
/// TemplateCharacter :: SourceCharacter but not one of ` or \ or $ or LineTerminator
fn parseTemplateCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eat("${"))) |_| return error.JsMalformed;
    if (w(p.eatByte('$'))) |_| return;
    if (w(p.eatByte('\\'))) |_| {
        if (w(parseTemplateEscapeSequence(alloc, p))) |_| return;
        if (w(parseNotEscapeSequence(alloc, p))) |_| return;
        if (w(parseLineTerminatorSequence(alloc, p))) |_| return;
        return error.JsMalformed;
    }
    if (w(parseLineTerminatorSequence(alloc, p))) |_| return;
    if (w(p.eatByte('`'))) |_| return error.JsMalformed;
    if (w(parseSourceCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// TemplateTail :: } TemplateCharacters? `
fn parseTemplateTail(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("}");
    _ = try parseTemplateCharacters(alloc, p);
    try p.eat("`");
}

/// TemplateMiddleList[Yield, Await, Tagged] : TemplateMiddle Expression[+In, ?Yield, ?Await]
/// TemplateMiddleList[Yield, Await, Tagged] : TemplateMiddleList[?Yield, ?Await, ?Tagged] TemplateMiddle Expression[+In, ?Yield, ?Await]
fn parseTemplateMiddleList(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, Tagged: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    _ = Tagged;
    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseTemplateMiddle(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        _ = try parseExpression(alloc, p, true, Yield, Await);
    }
}

/// EqualityExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] == RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] != RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] === RelationalExpression[?In, ?Yield, ?Await]
/// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] !== RelationalExpression[?In, ?Yield, ?Await]
fn parseEqualityExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseRelationalExpression(alloc, p, In, Yield, Await);
    _ = blk: {
        if (w(p.eatTok("==="))) |_| break :blk;
        if (w(p.eatTok("!=="))) |_| break :blk;
        if (w(p.eatTok("=="))) |_| break :blk;
        if (w(p.eatTok("!="))) |_| break :blk;
        return;
    };
    _ = try parseRelationalExpression(alloc, p, In, Yield, Await);
}

/// DecimalLiteral :: DecimalIntegerLiteral . DecimalDigits[+Sep]? ExponentPart[+Sep]?
/// DecimalLiteral :: . DecimalDigits[+Sep] ExponentPart[+Sep]?
/// DecimalLiteral :: DecimalIntegerLiteral ExponentPart[+Sep]?
fn parseDecimalLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;

    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        parseDecimalIntegerLiteral(alloc, p) catch break :blk;
        p.eat(".") catch break :blk;
        parseDecimalDigits(alloc, p, true) catch {};
        parseExponentPart(alloc, p, true) catch {};
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        p.eat(".") catch break :blk;
        parseDecimalDigits(alloc, p, true) catch {};
        parseExponentPart(alloc, p, true) catch {};
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        parseDecimalIntegerLiteral(alloc, p) catch break :blk;
        parseExponentPart(alloc, p, true) catch {};
        good = true;
        return;
    };
    return error.JsMalformed;
}

/// DecimalBigIntegerLiteral :: 0 BigIntLiteralSuffix
/// DecimalBigIntegerLiteral :: NonZeroDigit DecimalDigits[+Sep]? BigIntLiteralSuffix
/// DecimalBigIntegerLiteral :: NonZeroDigit NumericLiteralSeparator DecimalDigits[+Sep] BigIntLiteralSuffix
fn parseDecimalBigIntegerLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    const S = struct {
        fn op1(alloc2: std.mem.Allocator, p2: *Parser) anyerror!void {
            var old_idx = p2.idx;
            errdefer p2.idx = old_idx;
            try p2.eat("0");
            _ = try parseBigIntLiteralSuffix(alloc2, p2);
        }
        fn op2(alloc2: std.mem.Allocator, p2: *Parser) anyerror!void {
            var old_idx = p2.idx;
            errdefer p2.idx = old_idx;
            _ = try parseNonZeroDigit(alloc2, p2);
            _ = parseDecimalDigits(alloc2, p2, true) catch {};
            _ = try parseBigIntLiteralSuffix(alloc2, p2);
        }
        fn op3(alloc2: std.mem.Allocator, p2: *Parser) anyerror!void {
            var old_idx = p2.idx;
            errdefer p2.idx = old_idx;
            _ = try parseNonZeroDigit(alloc2, p2);
            _ = try parseNumericLiteralSeparator(alloc2, p2);
            _ = parseDecimalDigits(alloc2, p2, true) catch {};
            _ = try parseBigIntLiteralSuffix(alloc2, p2);
        }
    };

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(S.op1(alloc, p))) |_| return;
    if (w(S.op2(alloc, p))) |_| return;
    if (w(S.op3(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// NonDecimalIntegerLiteral[Sep] :: BinaryIntegerLiteral[?Sep]
/// NonDecimalIntegerLiteral[Sep] :: OctalIntegerLiteral[?Sep]
/// NonDecimalIntegerLiteral[Sep] :: HexIntegerLiteral[?Sep]
fn parseNonDecimalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseBinaryIntegerLiteral(alloc, p, Sep))) |_| return;
    if (w(parseOctalIntegerLiteral(alloc, p, Sep))) |_| return;
    if (w(parseHexIntegerLiteral(alloc, p, Sep))) |_| return;
    return error.JsMalformed;
}

/// BigIntLiteralSuffix :: n
fn parseBigIntLiteralSuffix(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('n'))) |_| return;
    return error.JsMalformed;
}

/// SpreadElement[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
fn parseSpreadElement(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("...");
    _ = try parseAssignmentExpression(alloc, p, true, Yield, Await);
}

/// PropertyDefinition[Yield, Await] : IdentifierReference[?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : CoverInitializedName[?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : PropertyName[?Yield, ?Await] : AssignmentExpression[+In, ?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : MethodDefinition[?Yield, ?Await]
/// PropertyDefinition[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
fn parsePropertyDefinition(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    // var old_idx = p.idx;
    // errdefer p.idx = old_idx;

    _ = blk: {
        var old_idx = p.idx;
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // PropertyDefinition[Yield, Await] : PropertyName[?Yield, ?Await] : AssignmentExpression[+In, ?Yield, ?Await]
        parsePropertyName(alloc, p, Yield, Await) catch break :blk;
        p.eatTok(":") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var old_idx = p.idx;
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // PropertyDefinition[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
        p.eatTok("...") catch break :blk;
        parseAssignmentExpression(alloc, p, true, Yield, Await) catch break :blk;
        good = true;
        return;
    };

    if (w(parseCoverInitializedName(alloc, p, Yield, Await))) |_| return;
    if (w(parseMethodDefinition(alloc, p, Yield, Await))) |_| return;
    if (w(parseIdentifierReference(alloc, p, Yield, Await))) |_| return;

    return error.JsMalformed;
}

/// RegularExpressionFirstChar :: RegularExpressionNonTerminator but not one of * or \ or / or [
/// RegularExpressionFirstChar :: RegularExpressionBackslashSequence
/// RegularExpressionFirstChar :: RegularExpressionClass
fn parseRegularExpressionFirstChar(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseRegularExpressionBackslashSequence(alloc, p))) |_| return;
    if (w(parseRegularExpressionClass(alloc, p))) |_| return;
    if (w(p.eat("*"))) |_| return error.JsMalformed;
    if (w(p.eat("\\"))) |_| return error.JsMalformed;
    if (w(p.eat("/"))) |_| return error.JsMalformed;
    if (w(p.eat("["))) |_| return error.JsMalformed;
    if (w(parseRegularExpressionNonTerminator(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// TemplateEscapeSequence :: CharacterEscapeSequence
/// TemplateEscapeSequence :: 0 [lookahead ∉ DecimalDigit]
/// TemplateEscapeSequence :: HexEscapeSequence
/// TemplateEscapeSequence :: UnicodeEscapeSequence
fn parseTemplateEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseCharacterEscapeSequence(alloc, p))) |_| return;
    if (w(p.eat("0"))) |_| {
        if (w(parseDecimalDigit(alloc, p))) |_| return error.JsMalformed;
        return;
    }
    if (w(parseHexEscapeSequence(alloc, p))) |_| return;
    if (w(parseUnicodeEscapeSequence(alloc, p))) |_| return;
    return error.JsMalformed;
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
fn parseNotEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    //TODO:
    _ = alloc;
    _ = &parseDecimalDigit;
    _ = &parseHexDigit;
    _ = &parseNotCodePoint;
    _ = &parseCodePoint;
    return error.TODO;
}

/// LineTerminatorSequence :: <LF>
/// LineTerminatorSequence :: <CR> [lookahead ≠ <LF>]
/// LineTerminatorSequence :: <LS>
/// LineTerminatorSequence :: <PS>
/// LineTerminatorSequence :: <CR> <LF>
fn parseLineTerminatorSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eat("\r\n"))) |_| return;
    if (w(p.eatByte(0x0A))) |_| return; // <LF>
    if (w(p.eatByte(0x0D))) |_| return; // <CR>
    if (w(p.eatCp(0x2028))) |_| return; // <LS>
    if (w(p.eatCp(0x2029))) |_| return; // <PS>
    return error.JsMalformed;
}

///  SourceCharacter ::
/// any Unicode code point
fn parseSourceCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    @setEvalBranchQuota(10_000);
    inline for (unicodeucd.blocks.data) |item| {
        if (w(p.eatRangeM(item.from, item.to))) |_| return;
    }
    return error.JsMalformed;
}

/// TemplateMiddle :: } TemplateCharacters? ${
fn parseTemplateMiddle(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("}");
    _ = try parseTemplateCharacters(alloc, p);
    try p.eat("${");
}

/// RelationalExpression[In, Yield, Await] : ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] < ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] > ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] <= ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] >= ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] instanceof ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : [+In] RelationalExpression[+In, ?Yield, ?Await] in ShiftExpression[?Yield, ?Await]
/// RelationalExpression[In, Yield, Await] : [+In] PrivateIdentifier in ShiftExpression[?Yield, ?Await]
fn parseRelationalExpression(alloc: std.mem.Allocator, p: *Parser, In: bool, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = blk: {
        if (w(parseShiftExpression(alloc, p, Yield, Await))) |_| break :blk;
        _ = blk2: {
            if (!In) break :blk2;
            parsePrivateIdentifier(alloc, p) catch break :blk2;
            p.eatTok("in") catch break :blk2;
            parseShiftExpression(alloc, p, Yield, Await) catch break :blk2;
            break :blk;
        };
        return error.JsMalformed;
    };
    _ = blk: {
        if (w(p.eatTok("<="))) |_| break :blk;
        if (w(p.eatTok(">="))) |_| break :blk;
        if (w(p.eatTok("<"))) |_| break :blk;
        if (w(p.eatTok(">"))) |_| break :blk;
        if (w(p.eatTok("instanceof"))) |_| break :blk;
        if (In) if (w(p.eatTok("in"))) |_| break :blk;
        return;
    };
    try parseShiftExpression(alloc, p, Yield, Await);
}

/// DecimalIntegerLiteral :: 0
/// DecimalIntegerLiteral :: NonZeroDigit
/// DecimalIntegerLiteral :: NonZeroDigit NumericLiteralSeparator? DecimalDigits[+Sep]
/// DecimalIntegerLiteral :: NonOctalDecimalIntegerLiteral
fn parseDecimalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eat("0"))) |_| return;
    if (w(parseNonOctalDecimalIntegerLiteral(alloc, p))) |_| return;
    _ = try parseNonZeroDigit(alloc, p);
    parseNumericLiteralSeparator(alloc, p) catch return;
    _ = try parseDecimalDigits(alloc, p, true);
}

/// DecimalDigits[Sep] :: DecimalDigit
/// DecimalDigits[Sep] :: DecimalDigits[?Sep] DecimalDigit
/// DecimalDigits[Sep] :: [+Sep] DecimalDigits[+Sep] NumericLiteralSeparator DecimalDigit
fn parseDecimalDigits(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 0) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseDecimalDigit(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        if (Sep) _ = parseNumericLiteralSeparator(alloc, p) catch {};
    }
}

/// ExponentPart[Sep] :: ExponentIndicator SignedInteger[?Sep]
fn parseExponentPart(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseExponentIndicator(alloc, p);
    _ = try parseSignedInteger(alloc, p, Sep);
}

///  NonZeroDigit :: one of
/// 1 2 3 4 5 6 7 8 9
fn parseNonZeroDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatRange('1', '9'))) |_| return;
    return error.JsMalformed;
}

/// NumericLiteralSeparator :: _
fn parseNumericLiteralSeparator(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('_'))) |_| return;
    return error.JsMalformed;
}

/// BinaryIntegerLiteral[Sep] :: 0b BinaryDigits[?Sep]
/// BinaryIntegerLiteral[Sep] :: 0B BinaryDigits[?Sep]
fn parseBinaryIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    p.eat("0b") catch p.eat("0B") catch return error.JsMalformed;
    _ = try parseBinaryDigits(alloc, p, Sep);
}

/// OctalIntegerLiteral[Sep] :: 0o OctalDigits[?Sep]
/// OctalIntegerLiteral[Sep] :: 0O OctalDigits[?Sep]
fn parseOctalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    p.eat("0o") catch p.eat("0O") catch return error.JsMalformed;
    _ = try parseOctalDigits(alloc, p, Sep);
}

/// HexIntegerLiteral[Sep] :: 0x HexDigits[?Sep]
/// HexIntegerLiteral[Sep] :: 0X HexDigits[?Sep]
fn parseHexIntegerLiteral(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    p.eat("0x") catch p.eat("0X") catch return error.JsMalformed;
    _ = try parseHexDigits(alloc, p, Sep);
}

/// DoubleStringCharacter :: SourceCharacter but not one of " or \ or LineTerminator
/// DoubleStringCharacter :: <LS>
/// DoubleStringCharacter :: <PS>
/// DoubleStringCharacter :: \ EscapeSequence
/// DoubleStringCharacter :: LineContinuation
fn parseDoubleStringCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatCp(0x2028))) |_| return; // <LS>
    if (w(p.eatCp(0x2029))) |_| return; // <PS>
    if (w(p.eatByte('\\'))) |_| {
        if (w(parseEscapeSequence(alloc, p))) |_| return;
        if (w(parseLineTerminatorSequence(alloc, p))) |_| return;
        return error.JsMalformed;
    }
    if (w(p.eatByte('"'))) |_| return error.JsMalformed;
    if (w(parseLineTerminator(alloc, p))) |_| return error.JsMalformed;
    if (w(parseSourceCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// SingleStringCharacter :: SourceCharacter but not one of ' or \ or LineTerminator
/// SingleStringCharacter :: <LS>
/// SingleStringCharacter :: <PS>
/// SingleStringCharacter :: \ EscapeSequence
/// SingleStringCharacter :: LineContinuation
fn parseSingleStringCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eatCp(0x2028))) |_| return; // <LS>
    if (w(p.eatCp(0x2029))) |_| return; // <PS>
    if (w(p.eatByte('\\'))) |_| {
        if (w(parseEscapeSequence(alloc, p))) |_| return;
        if (w(parseLineTerminatorSequence(alloc, p))) |_| return;
        return error.JsMalformed;
    }
    if (w(p.eatByte('\''))) |_| return error.JsMalformed;
    if (w(parseLineTerminator(alloc, p))) |_| return error.JsMalformed;
    if (w(parseSourceCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// CoverInitializedName[Yield, Await] : IdentifierReference[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]
fn parseCoverInitializedName(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseIdentifierReference(alloc, p, Yield, Await);
    _ = try parseInitializer(alloc, p, true, Yield, Await);
}

///  RegularExpressionNonTerminator ::
/// SourceCharacter but not LineTerminator
fn parseRegularExpressionNonTerminator(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseLineTerminator(alloc, p))) |_| return error.JsMalformed;
    if (w(parseSourceCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// RegularExpressionBackslashSequence :: \ RegularExpressionNonTerminator
fn parseRegularExpressionBackslashSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("\\");
    _ = try parseRegularExpressionNonTerminator(alloc, p);
}

/// RegularExpressionClass :: [ RegularExpressionClassChars ]
fn parseRegularExpressionClass(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("[");
    _ = try parseRegularExpressionClassChars(alloc, p);
    try p.eat("]");
}

/// RegularExpressionChar :: RegularExpressionNonTerminator but not one of \ or / or [
/// RegularExpressionChar :: RegularExpressionBackslashSequence
/// RegularExpressionChar :: RegularExpressionClass
fn parseRegularExpressionChar(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseRegularExpressionBackslashSequence(alloc, p))) |_| return;
    if (w(parseRegularExpressionClass(alloc, p))) |_| return;
    if (w(p.eat("\\"))) |_| return error.JsMalformed;
    if (w(p.eat("/"))) |_| return error.JsMalformed;
    if (w(p.eat("["))) |_| return error.JsMalformed;
    if (w(parseRegularExpressionNonTerminator(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// CharacterEscapeSequence :: SingleEscapeCharacter
/// CharacterEscapeSequence :: NonEscapeCharacter
fn parseCharacterEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseSingleEscapeCharacter(alloc, p))) |_| return;
    if (w(parseNonEscapeCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}

///  DecimalDigit :: one of
/// 0 1 2 3 4 5 6 7 8 9
fn parseDecimalDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatRange('0', '9'))) |_| return;
    return error.JsMalformed;
}

/// HexEscapeSequence :: x HexDigit HexDigit
fn parseHexEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("x");
    _ = try parseHexDigit(alloc, p);
    _ = try parseHexDigit(alloc, p);
}

/// NotCodePoint :: HexDigits[~Sep] but only if MV of HexDigits > 0x10FFFF
fn parseNotCodePoint(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    //TODO:
    _ = alloc;
    return error.TODO;
}

/// ShiftExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await]
/// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] << AdditiveExpression[?Yield, ?Await]
/// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] >> AdditiveExpression[?Yield, ?Await]
/// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] >>> AdditiveExpression[?Yield, ?Await]
fn parseShiftExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseAdditiveExpression(alloc, p, Yield, Await);
    _ = blk: {
        if (w(p.eatTok(">>>"))) |_| break :blk;
        if (w(p.eatTok(">>"))) |_| break :blk;
        if (w(p.eatTok("<<"))) |_| break :blk;
        return;
    };
    _ = try parseAdditiveExpression(alloc, p, Yield, Await);
}

/// NonOctalDecimalIntegerLiteral :: 0 NonOctalDigit
/// NonOctalDecimalIntegerLiteral :: LegacyOctalLikeDecimalIntegerLiteral NonOctalDigit
/// NonOctalDecimalIntegerLiteral :: NonOctalDecimalIntegerLiteral DecimalDigit
fn parseNonOctalDecimalIntegerLiteral(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eat("0");
    _ = try parseNonOctalDigit(alloc, p);
    var i: usize = 0;
    while (true) : (i += 1) {
        _ = parseDecimalDigit(alloc, p) catch break;
    }
}

///  ExponentIndicator :: one of
/// e E
fn parseExponentIndicator(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('e'))) |_| return;
    if (w(p.eatByte('E'))) |_| return;
    return error.JsMalformed;
}

/// SignedInteger[Sep] :: DecimalDigits[?Sep]
/// SignedInteger[Sep] :: + DecimalDigits[?Sep]
/// SignedInteger[Sep] :: - DecimalDigits[?Sep]
fn parseSignedInteger(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = blk: {
        if (w(p.eat("+"))) |_| break :blk;
        if (w(p.eat("-"))) |_| break :blk;
        break :blk {};
    };
    _ = try parseDecimalDigits(alloc, p, Sep);
}

/// BinaryDigits[Sep] :: BinaryDigit
/// BinaryDigits[Sep] :: BinaryDigits[?Sep] BinaryDigit
/// BinaryDigits[Sep] :: [+Sep] BinaryDigits[+Sep] NumericLiteralSeparator BinaryDigit
fn parseBinaryDigits(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 0) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseBinaryDigit(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        if (Sep) _ = parseNumericLiteralSeparator(alloc, p) catch {};
    }
}

/// OctalDigits[Sep] :: OctalDigit
/// OctalDigits[Sep] :: OctalDigits[?Sep] OctalDigit
/// OctalDigits[Sep] :: [+Sep] OctalDigits[+Sep] NumericLiteralSeparator OctalDigit
fn parseOctalDigits(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 0) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseOctalDigit(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        if (Sep) _ = parseNumericLiteralSeparator(alloc, p) catch {};
    }
}

/// HexDigits[Sep] :: HexDigit
/// HexDigits[Sep] :: HexDigits[?Sep] HexDigit
/// HexDigits[Sep] :: [+Sep] HexDigits[+Sep] NumericLiteralSeparator HexDigit
fn parseHexDigits(alloc: std.mem.Allocator, p: *Parser, Sep: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 0) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseHexDigit(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        if (Sep) _ = parseNumericLiteralSeparator(alloc, p) catch {};
    }
}

/// EscapeSequence :: CharacterEscapeSequence
/// EscapeSequence :: 0 [lookahead ∉ DecimalDigit]
/// EscapeSequence :: LegacyOctalEscapeSequence
/// EscapeSequence :: NonOctalDecimalEscapeSequence
/// EscapeSequence :: HexEscapeSequence
/// EscapeSequence :: UnicodeEscapeSequence
fn parseEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseCharacterEscapeSequence(alloc, p))) |_| return;
    if (w(p.eat("0"))) |_| {
        if (w(parseDecimalDigit(alloc, p))) |_| return error.JsMalformed;
        return;
    }
    if (w(parseNonOctalDecimalEscapeSequence(alloc, p))) |_| return;
    if (w(parseHexEscapeSequence(alloc, p))) |_| return;
    if (w(parseUnicodeEscapeSequence(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// RegularExpressionClassChars :: [empty]
/// RegularExpressionClassChars :: RegularExpressionClassChars RegularExpressionClassChar
fn parseRegularExpressionClassChars(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    while (w(parseRegularExpressionClassChar(alloc, p))) |_| {
        //
    }
}

///  SingleEscapeCharacter :: one of
/// ' " \ b f n r t v
fn parseSingleEscapeCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatAny(&.{ '\'', '"', '\\', 'b', 'f', 'n', 'r', 't', 'v' }))) |_| return;
    return error.JsMalformed;
}

/// NonEscapeCharacter :: SourceCharacter but not one of EscapeCharacter or LineTerminator
fn parseNonEscapeCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseEscapeCharacter(alloc, p))) |_| return error.JsMalformed;
    if (w(parseLineTerminator(alloc, p))) |_| return error.JsMalformed;
    if (w(parseSourceCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// AdditiveExpression[Yield, Await] : MultiplicativeExpression[?Yield, ?Await]
/// AdditiveExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await] + MultiplicativeExpression[?Yield, ?Await]
/// AdditiveExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await] - MultiplicativeExpression[?Yield, ?Await]
fn parseAdditiveExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseMultiplicativeExpression(alloc, p, Yield, Await);
    _ = blk: {
        if (w(p.eatTok("+"))) |_| break :blk;
        if (w(p.eatTok("-"))) |_| break :blk;
        return;
    };
    _ = try parseMultiplicativeExpression(alloc, p, Yield, Await);
}

///  NonOctalDigit :: one of
/// 8 9
fn parseNonOctalDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('8'))) |_| return;
    if (w(p.eatByte('9'))) |_| return;
    return error.JsMalformed;
}

///  BinaryDigit :: one of
/// 0 1
fn parseBinaryDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('0'))) |_| return;
    if (w(p.eatByte('1'))) |_| return;
    return error.JsMalformed;
}

///  OctalDigit :: one of
/// 0 1 2 3 4 5 6 7
fn parseOctalDigit(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatRange('0', '7'))) |_| return;
    return error.JsMalformed;
}

///  NonOctalDecimalEscapeSequence :: one of
/// 8 9
fn parseNonOctalDecimalEscapeSequence(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('8'))) |_| return;
    if (w(p.eatByte('9'))) |_| return;
    return error.JsMalformed;
}

/// RegularExpressionClassChar :: RegularExpressionNonTerminator but not one of ] or \
/// RegularExpressionClassChar :: RegularExpressionBackslashSequence
fn parseRegularExpressionClassChar(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseRegularExpressionBackslashSequence(alloc, p))) |_| return;
    if (w(p.eat("\\"))) |_| return error.JsMalformed;
    if (w(p.eat("]"))) |_| return error.JsMalformed;
    if (w(parseRegularExpressionNonTerminator(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// MultiplicativeExpression[Yield, Await] : ExponentiationExpression[?Yield, ?Await]
/// MultiplicativeExpression[Yield, Await] : MultiplicativeExpression[?Yield, ?Await] MultiplicativeOperator ExponentiationExpression[?Yield, ?Await]
fn parseMultiplicativeExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseExponentiationExpression(alloc, p, Yield, Await);
    _ = parseMultiplicativeOperator(alloc, p) catch return;
    _ = try parseExponentiationExpression(alloc, p, Yield, Await);
}

/// ExponentiationExpression[Yield, Await] : UnaryExpression[?Yield, ?Await]
/// ExponentiationExpression[Yield, Await] : UpdateExpression[?Yield, ?Await] ** ExponentiationExpression[?Yield, ?Await]
fn parseExponentiationExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    const update = try parseUpdateExpression(alloc, p, Yield, Await);

    if (w(parseUnaryExpression(alloc, p, Yield, Await, update))) |_| return;

    try p.eatTok("**");
    _ = try parseExponentiationExpression(alloc, p, Yield, Await);
}

///  MultiplicativeOperator : one of
/// * / %
fn parseMultiplicativeOperator(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte('*'))) |_| return;
    if (w(p.eatByte('/'))) |_| return;
    if (w(p.eatByte('%'))) |_| return;
    return error.JsMalformed;
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
//FIXME:
fn parseUnaryExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool, _maybeUpdateExpression: ?void) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (_maybeUpdateExpression) |_| return;

    _ = blk: {
        if (w(p.eatTok("delete"))) |_| break :blk;
        if (w(p.eatTok("void"))) |_| break :blk;
        if (w(p.eatTok("typeof"))) |_| break :blk;
        if (w(p.eatTok("+"))) |_| break :blk;
        if (w(p.eatTok("-"))) |_| break :blk;
        if (w(p.eatTok("~"))) |_| break :blk;
        if (w(p.eatTok("!"))) |_| break :blk;
        if (Await) if (w(p.eatTok("await"))) |_| break :blk;
        return error.JsMalformed;
    };
    _ = try parseUnaryExpression(alloc, p, Yield, Await, null);
}

/// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await]
/// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await] [no LineTerminator here] ++
/// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await] [no LineTerminator here] --
/// UpdateExpression[Yield, Await] : ++ UnaryExpression[?Yield, ?Await]
/// UpdateExpression[Yield, Await] : -- UnaryExpression[?Yield, ?Await]
fn parseUpdateExpression(alloc: std.mem.Allocator, p: *Parser, Yield: bool, Await: bool) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseLeftHandSideExpression(alloc, p, Yield, Await))) |_| {
        if (w(p.eatTok("++"))) |_| return;
        if (w(p.eatTok("--"))) |_| return;
        return;
    }
    _ = blk: {
        if (w(p.eatTok("++"))) |_| break :blk;
        if (w(p.eatTok("--"))) |_| break :blk;
        return error.JsMalformed;
    };
    _ = try parseUnaryExpression(alloc, p, Yield, Await, null);
}

/// Module : ModuleBody?
fn parseModule(alloc: std.mem.Allocator, p: *Parser) !void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return try parseModuleBody(alloc, p);
}

/// ModuleBody : ModuleItemList
fn parseModuleBody(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseModuleItemList(alloc, p);
}

/// ModuleItemList : ModuleItem
/// ModuleItemList : ModuleItemList ModuleItem
fn parseModuleItemList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseModuleItem(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        if (p.end) break;
    }
}

/// ModuleItem : ImportDeclaration
/// ModuleItem : ExportDeclaration
/// ModuleItem : StatementListItem[~Yield, +Await, ~Return]
fn parseModuleItem(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseImportDeclaration(alloc, p))) |_| return;
    if (w(parseExportDeclaration(alloc, p))) |_| return;
    if (w(parseStatementListItem(alloc, p, false, true, false))) |_| return;
    return error.JsMalformed;
}

/// ImportDeclaration : import ImportClause FromClause ;
/// ImportDeclaration : import ModuleSpecifier ;
fn parseImportDeclaration(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("import");
    if (w(parseModuleSpecifier(alloc, p))) |_| {
        try p.eatTok(";");
        return;
    }
    _ = try parseImportClause(alloc, p);
    _ = try parseFromClause(alloc, p);
    try p.eatTok(";");
}

/// ExportDeclaration : export ExportFromClause FromClause ;
/// ExportDeclaration : export NamedExports ;
/// ExportDeclaration : export VariableStatement[~Yield, +Await]
/// ExportDeclaration : export Declaration[~Yield, +Await]
/// ExportDeclaration : export default HoistableDeclaration[~Yield, +Await, +Default]
/// ExportDeclaration : export default ClassDeclaration[~Yield, +Await, +Default]
/// ExportDeclaration : export default [lookahead ∉ { function, async [no LineTerminator here] function, class }] AssignmentExpression[+In, ~Yield, +Await] ;
fn parseExportDeclaration(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;

    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export ExportFromClause FromClause ;
        p.eatTok("export") catch break :blk;
        parseExportFromClause(alloc, p) catch break :blk;
        parseFromClause(alloc, p) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export NamedExports ;
        p.eatTok("export") catch break :blk;
        parseNamedExports(alloc, p) catch break :blk;
        p.eatTok(";") catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export VariableStatement[~Yield, +Await]
        p.eatTok("export") catch break :blk;
        parseVariableStatement(alloc, p, false, true) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export Declaration[~Yield, +Await]
        p.eatTok("export") catch break :blk;
        parseDeclaration(alloc, p, false, true) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export default HoistableDeclaration[~Yield, +Await, +Default]
        p.eatTok("export") catch break :blk;
        p.eatTok("default") catch break :blk;
        parseHoistableDeclaration(alloc, p, false, true, true) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export default ClassDeclaration[~Yield, +Await, +Default]
        p.eatTok("export") catch break :blk;
        p.eatTok("default") catch break :blk;
        parseClassDeclaration(alloc, p, false, true, true) catch break :blk;
        good = true;
        return;
    };
    _ = blk: {
        var good = false;
        defer if (!good) {
            p.idx = old_idx;
        };
        // ExportDeclaration : export default [lookahead ∉ { function, async [no LineTerminator here] function, class }] AssignmentExpression[+In, ~Yield, +Await] ;
        p.eatTok("export") catch break :blk;
        p.eatTok("default") catch break :blk;
        if (w(p.eatTok("function"))) |_| break :blk;
        if (w(p.eatTok("class"))) |_| break :blk;
        _ = blk2: {
            p.eatTok("async") catch break :blk2;
            p.eatTok("function") catch break :blk2;
            break :blk;
        };
        parseAssignmentExpression(alloc, p, true, false, true) catch break :blk;
        p.eatTok(";") catch break :blk;
        good = true;
        return;
    };
    return error.JsMalformed;
}

/// ImportClause : ImportedDefaultBinding
/// ImportClause : NameSpaceImport
/// ImportClause : NamedImports
/// ImportClause : ImportedDefaultBinding , NameSpaceImport
/// ImportClause : ImportedDefaultBinding , NamedImports
fn parseImportClause(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseImportedDefaultBinding(alloc, p))) |_| return;
    if (w(parseNameSpaceImport(alloc, p))) |_| return;
    if (w(parseNamedImports(alloc, p))) |_| return;

    _ = try parseImportedDefaultBinding(alloc, p);
    try p.eatTok(",");
    if (w(parseNameSpaceImport(alloc, p))) |_| return;
    if (w(parseNamedImports(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// FromClause : from ModuleSpecifier
fn parseFromClause(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("from");
    _ = try parseModuleSpecifier(alloc, p);
}

/// ModuleSpecifier : StringLiteral
fn parseModuleSpecifier(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    try parseStringLiteral(alloc, p);
}

/// ExportFromClause : *
/// ExportFromClause : * as ModuleExportName
/// ExportFromClause : NamedExports
fn parseExportFromClause(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseNamedImports(alloc, p))) |_| return;

    try p.eatTok("*");
    p.eatTok("as") catch return;
    _ = try parseModuleExportName(alloc, p);
}

/// ImportedDefaultBinding : ImportedBinding
fn parseImportedDefaultBinding(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseImportedBinding(alloc, p);
}

/// NameSpaceImport : * as ImportedBinding
fn parseNameSpaceImport(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("*");
    try p.eatTok("as");
    _ = try parseImportedBinding(alloc, p);
}

/// NamedImports : { }
/// NamedImports : { ImportsList }
/// NamedImports : { ImportsList , }
fn parseNamedImports(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("{");
    if (w(p.eatTok("}"))) |_| return;
    _ = try parseImportsList(alloc, p);
    if (w(p.eatTok("}"))) |_| return;
    try p.eatTok(",");
    try p.eatTok("}");
}

/// ModuleExportName : IdentifierName
/// ModuleExportName : StringLiteral
fn parseModuleExportName(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseIdentifierName(alloc, p))) |_| return;
    if (w(parseStringLiteral(alloc, p))) |_| return;
    return error.JsMalformed;
}

/// NamedExports : { }
/// NamedExports : { ExportsList }
/// NamedExports : { ExportsList , }
fn parseNamedExports(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    try p.eatTok("{");
    if (w(p.eatTok("}"))) |_| return;
    _ = try parseExportsList(alloc, p);
    if (w(p.eatTok("}"))) |_| return;
    try p.eatTok(",");
    try p.eatTok("}");
}

/// ImportedBinding : BindingIdentifier[~Yield, +Await]
fn parseImportedBinding(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    return parseBindingIdentifier(alloc, p, false, true);
}

/// ImportsList : ImportSpecifier
/// ImportsList : ImportsList , ImportSpecifier
fn parseImportsList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseImportSpecifier(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// ExportsList : ExportSpecifier
/// ExportsList : ExportsList , ExportSpecifier
fn parseExportsList(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var i: usize = 0;
    while (true) : (i += 1) {
        var old_idx = p.idx;
        errdefer p.idx = old_idx;

        _ = parseExportSpecifier(alloc, p) catch if (i == 0) return error.JsMalformed else break;
        p.eatTok(",") catch break;
    }
}

/// ImportSpecifier : ImportedBinding
/// ImportSpecifier : ModuleExportName as ImportedBinding
fn parseImportSpecifier(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(parseImportedBinding(alloc, p))) |_| return;

    try parseModuleExportName(alloc, p);
    p.eatTok("as") catch return;
    _ = try parseImportedBinding(alloc, p);
}

/// ExportSpecifier : ModuleExportName
/// ExportSpecifier : ModuleExportName as ModuleExportName
fn parseExportSpecifier(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = try parseModuleExportName(alloc, p);
    p.eatTok("as") catch return;
    _ = try parseModuleExportName(alloc, p);
}

/// LineTerminator :: <LF>
/// LineTerminator :: <CR>
/// LineTerminator :: <LS>
/// LineTerminator :: <PS>
fn parseLineTerminator(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    _ = alloc;
    if (w(p.eatByte(0x0A))) |_| return; // <LF>
    if (w(p.eatByte(0x0D))) |_| return; // <CR>
    if (w(p.eatCp(0x2028))) |_| return; // <LS>
    if (w(p.eatCp(0x2029))) |_| return; // <PS>
    return error.JsMalformed;
}

/// EscapeCharacter :: SingleEscapeCharacter
/// EscapeCharacter :: DecimalDigit
/// EscapeCharacter :: x
/// EscapeCharacter :: u
fn parseEscapeCharacter(alloc: std.mem.Allocator, p: *Parser) anyerror!void {
    //
    const t = tracer.trace(@src(), "({d})", .{p.idx});
    defer t.end();

    var old_idx = p.idx;
    errdefer p.idx = old_idx;

    if (w(p.eat("x"))) |_| return;
    if (w(p.eat("u"))) |_| return;
    if (w(parseHexDigit(alloc, p))) |_| return;
    if (w(parseSingleEscapeCharacter(alloc, p))) |_| return;
    return error.JsMalformed;
}
