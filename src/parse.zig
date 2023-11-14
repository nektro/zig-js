//! grammar rules current as of Draft ECMA-262 / November 3, 2023

const std = @import("std");

pub fn do() !void {
    //
    _ = &parseScript;
    _ = &parseModule;
}

// Script : ScriptBody?
fn parseScript() !?void {
    //
    _ = &parseScriptBody;
}

// ScriptBody : StatementList[~Yield, ~Await, ~Return]
fn parseScriptBody() !?void {
    //
    _ = &parseStatementList;
}

// StatementList[Yield, Await, Return] : StatementListItem[?Yield, ?Await, ?Return]
// StatementList[Yield, Await, Return] : StatementList[?Yield, ?Await, ?Return] StatementListItem[?Yield, ?Await, ?Return]
fn parseStatementList() !?void {
    //
    _ = &parseStatementListItem;
}

// StatementListItem[Yield, Await, Return] : Statement[?Yield, ?Await, ?Return]
// StatementListItem[Yield, Await, Return] : Declaration[?Yield, ?Await]
fn parseStatementListItem() !?void {
    //
    _ = &parseStatement;
    _ = &parseDeclaration;
}

// Statement[Yield, Await, Return] : BlockStatement[?Yield, ?Await, ?Return]
// Statement[Yield, Await, Return] : VariableStatement[?Yield, ?Await]
// Statement[Yield, Await, Return] : EmptyStatement
// Statement[Yield, Await, Return] : ExpressionStatement[?Yield, ?Await]
// Statement[Yield, Await, Return] : IfStatement[?Yield, ?Await, ?Return]
// Statement[Yield, Await, Return] : BreakableStatement[?Yield, ?Await, ?Return]
// Statement[Yield, Await, Return] : ContinueStatement[?Yield, ?Await]
// Statement[Yield, Await, Return] : BreakStatement[?Yield, ?Await]
// Statement[Yield, Await, Return] : [+Return] ReturnStatement[?Yield, ?Await]
// Statement[Yield, Await, Return] : WithStatement[?Yield, ?Await, ?Return]
// Statement[Yield, Await, Return] : LabelledStatement[?Yield, ?Await, ?Return]
// Statement[Yield, Await, Return] : ThrowStatement[?Yield, ?Await]
// Statement[Yield, Await, Return] : TryStatement[?Yield, ?Await, ?Return]
// Statement[Yield, Await, Return] : DebuggerStatement
fn parseStatement() !?void {
    //
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
}

// Declaration[Yield, Await] : HoistableDeclaration[?Yield, ?Await, ~Default]
// Declaration[Yield, Await] : ClassDeclaration[?Yield, ?Await, ~Default]
// Declaration[Yield, Await] : LexicalDeclaration[+In, ?Yield, ?Await]
fn parseDeclaration() !?void {
    //
    _ = &parseHoistableDeclaration;
    _ = &parseClassDeclaration;
    _ = &parseLexicalDeclaration;
}

// BlockStatement[Yield, Await, Return] : Block[?Yield, ?Await, ?Return]
fn parseBlockStatement() !?void {
    //
    _ = &parseBlock;
}

// VariableStatement[Yield, Await] : var VariableDeclarationList[+In, ?Yield, ?Await] ;
fn parseVariableStatement() !?void {
    //
    _ = &parseVariableDeclarationList;
}

// EmptyStatement : ;
fn parseEmptyStatement() !?void {
    //
}

// ExpressionStatement[Yield, Await] : [lookahead ∉ { {, function, async [no LineTerminator here] function, class, let [ }] Expression[+In, ?Yield, ?Await] ;
fn parseExpressionStatement() !?void {
    //
    _ = &parseExpression;
}

// IfStatement[Yield, Await, Return] : if ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return] else Statement[?Yield, ?Await, ?Return]
// IfStatement[Yield, Await, Return] : if ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return] [lookahead ≠ else]
fn parseIfStatement() !?void {
    //
    _ = &parseExpression;
    _ = &parseStatement;
}

// BreakableStatement[Yield, Await, Return] : IterationStatement[?Yield, ?Await, ?Return]
// BreakableStatement[Yield, Await, Return] : SwitchStatement[?Yield, ?Await, ?Return]
fn parseBreakableStatement() !?void {
    //
    _ = &parseIterationStatement;
    _ = &parseSwitchStatement;
}

// ContinueStatement[Yield, Await] : continue ;
// ContinueStatement[Yield, Await] : continue [no LineTerminator here] LabelIdentifier[?Yield, ?Await] ;
fn parseContinueStatement() !?void {
    //
    _ = &parseLabelIdentifier;
}

// BreakStatement[Yield, Await] : break ;
// BreakStatement[Yield, Await] : break [no LineTerminator here] LabelIdentifier[?Yield, ?Await] ;
fn parseBreakStatement() !?void {
    //
    _ = &parseLabelIdentifier;
}

// ReturnStatement[Yield, Await] : return ;
// ReturnStatement[Yield, Await] : return [no LineTerminator here] Expression[+In, ?Yield, ?Await] ;
fn parseReturnStatement() !?void {
    //
    _ = &parseExpression;
}

// LabelledStatement[Yield, Await, Return] : LabelIdentifier[?Yield, ?Await] : LabelledItem[?Yield, ?Await, ?Return]
fn parseLabelledStatement() !?void {
    //
    _ = &parseLabelIdentifier;
    _ = &parseLabelledItem;
}

// ThrowStatement[Yield, Await] : throw [no LineTerminator here] Expression[+In, ?Yield, ?Await] ;
fn parseThrowStatement() !?void {
    //
    _ = &parseExpression;
}

// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Catch[?Yield, ?Await, ?Return]
// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Finally[?Yield, ?Await, ?Return]
// TryStatement[Yield, Await, Return] : try Block[?Yield, ?Await, ?Return] Catch[?Yield, ?Await, ?Return] Finally[?Yield, ?Await, ?Return]
fn parseTryStatement() !?void {
    //
    _ = &parseBlock;
    _ = &parseCatch;
    _ = &parseFinally;
}

// DebuggerStatement : debugger ;
fn parseDebuggerStatement() !?void {
    //
}

// HoistableDeclaration[Yield, Await, Default] : FunctionDeclaration[?Yield, ?Await, ?Default]
// HoistableDeclaration[Yield, Await, Default] : GeneratorDeclaration[?Yield, ?Await, ?Default]
// HoistableDeclaration[Yield, Await, Default] : AsyncFunctionDeclaration[?Yield, ?Await, ?Default]
// HoistableDeclaration[Yield, Await, Default] : AsyncGeneratorDeclaration[?Yield, ?Await, ?Default]
fn parseHoistableDeclaration() !?void {
    //
    _ = &parseFunctionDeclaration;
    _ = &parseGeneratorDeclaration;
    _ = &parseAsyncFunctionDeclaration;
    _ = &parseAsyncGeneratorDeclaration;
}

// ClassDeclaration[Yield, Await, Default] : class BindingIdentifier[?Yield, ?Await] ClassTail[?Yield, ?Await]
// ClassDeclaration[Yield, Await, Default] : [+Default] class ClassTail[?Yield, ?Await]
fn parseClassDeclaration() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseClassTail;
}

// LexicalDeclaration[In, Yield, Await] : LetOrConst BindingList[?In, ?Yield, ?Await] ;
fn parseLexicalDeclaration() !?void {
    //
    _ = &parseLetOrConst;
    _ = &parseBindingList;
}

// Block[Yield, Await, Return] : { StatementList[?Yield, ?Await, ?Return]? }
fn parseBlock() !?void {
    //
}

// VariableDeclarationList[In, Yield, Await] : VariableDeclaration[?In, ?Yield, ?Await]
// VariableDeclarationList[In, Yield, Await] : VariableDeclarationList[?In, ?Yield, ?Await] , VariableDeclaration[?In, ?Yield, ?Await]
fn parseVariableDeclarationList() !?void {
    //
    _ = &parseVariableDeclaration;
}

// Expression[In, Yield, Await] : AssignmentExpression[?In, ?Yield, ?Await]
// Expression[In, Yield, Await] : Expression[?In, ?Yield, ?Await] , AssignmentExpression[?In, ?Yield, ?Await]
fn parseExpression() !?void {
    //
    _ = &parseAssignmentExpression;
}

// IterationStatement[Yield, Await, Return] : DoWhileStatement[?Yield, ?Await, ?Return]
// IterationStatement[Yield, Await, Return] : WhileStatement[?Yield, ?Await, ?Return]
// IterationStatement[Yield, Await, Return] : ForStatement[?Yield, ?Await, ?Return]
// IterationStatement[Yield, Await, Return] : ForInOfStatement[?Yield, ?Await, ?Return]
fn parseIterationStatement() !?void {
    //
    _ = &parseDoWhileStatement;
    _ = &parseWhileStatement;
    _ = &parseForStatement;
    _ = &parseForInOfStatement;
}

// SwitchStatement[Yield, Await, Return] : switch ( Expression[+In, ?Yield, ?Await] ) CaseBlock[?Yield, ?Await, ?Return]
fn parseSwitchStatement() !?void {
    //
    _ = &parseExpression;
    _ = &parseCaseBlock;
}

// LabelIdentifier[Yield, Await] : Identifier
// LabelIdentifier[Yield, Await] : [~Yield] yield
// LabelIdentifier[Yield, Await] : [~Await] await
fn parseLabelIdentifier() !?void {
    //
    _ = &parseIdentifier;
}

// LabelledItem[Yield, Await, Return] : Statement[?Yield, ?Await, ?Return]
// LabelledItem[Yield, Await, Return] : FunctionDeclaration[?Yield, ?Await, ~Default]
fn parseLabelledItem() !?void {
    //
    _ = &parseStatement;
    _ = &parseFunctionDeclaration;
}

// Catch[Yield, Await, Return] : catch ( CatchParameter[?Yield, ?Await] ) Block[?Yield, ?Await, ?Return]
// Catch[Yield, Await, Return] : catch Block[?Yield, ?Await, ?Return]
fn parseCatch() !?void {
    //
    _ = &parseCatchParameter;
    _ = &parseBlock;
}

// Finally[Yield, Await, Return] : finally Block[?Yield, ?Await, ?Return]
fn parseFinally() !?void {
    //
    _ = &parseBlock;
}

// FunctionDeclaration[Yield, Await, Default] : function BindingIdentifier[?Yield, ?Await] ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
// FunctionDeclaration[Yield, Await, Default] : [+Default] function ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
fn parseFunctionDeclaration() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseFunctionBody;
}

// GeneratorDeclaration[Yield, Await, Default] : function * BindingIdentifier[?Yield, ?Await] ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
// GeneratorDeclaration[Yield, Await, Default] : [+Default] function * ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorDeclaration() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseGeneratorBody;
}

// AsyncFunctionDeclaration[Yield, Await, Default] : async [no LineTerminator here] function BindingIdentifier[?Yield, ?Await] ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
// AsyncFunctionDeclaration[Yield, Await, Default] : [+Default] async [no LineTerminator here] function ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncFunctionDeclaration() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncFunctionBody;
}

// AsyncGeneratorDeclaration[Yield, Await, Default] : async [no LineTerminator here] function * BindingIdentifier[?Yield, ?Await] ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
// AsyncGeneratorDeclaration[Yield, Await, Default] : [+Default] async [no LineTerminator here] function * ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorDeclaration() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncGeneratorBody;
}

// BindingIdentifier[Yield, Await] : Identifier
// BindingIdentifier[Yield, Await] : yield
// BindingIdentifier[Yield, Await] : await
fn parseBindingIdentifier() !?void {
    //
    _ = &parseIdentifier;
}

// ClassTail[Yield, Await] : ClassHeritage[?Yield, ?Await]? { ClassBody[?Yield, ?Await]? }
fn parseClassTail() !?void {
    //
    _ = &parseClassHeritage;
    _ = &parseClassBody;
}

// LetOrConst : let
// LetOrConst : const
fn parseLetOrConst() !?void {
    //
}

// BindingList[In, Yield, Await] : LexicalBinding[?In, ?Yield, ?Await]
// BindingList[In, Yield, Await] : BindingList[?In, ?Yield, ?Await] , LexicalBinding[?In, ?Yield, ?Await]
fn parseBindingList() !?void {
    //
    _ = &parseLexicalBinding;
    _ = &parseBindingList;
}

// VariableDeclaration[In, Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]?
// VariableDeclaration[In, Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]
fn parseVariableDeclaration() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    _ = &parseInitializer;
}

// AssignmentExpression[In, Yield, Await] : ConditionalExpression[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : [+Yield] YieldExpression[?In, ?Await]
// AssignmentExpression[In, Yield, Await] : ArrowFunction[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : AsyncArrowFunction[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] = AssignmentExpression[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] AssignmentOperator AssignmentExpression[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] &&= AssignmentExpression[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] ||= AssignmentExpression[?In, ?Yield, ?Await]
// AssignmentExpression[In, Yield, Await] : LeftHandSideExpression[?Yield, ?Await] ??= AssignmentExpression[?In, ?Yield, ?Await]
fn parseAssignmentExpression() !?void {
    //
    _ = &parseConditionalExpression;
    _ = &parseYieldExpression;
    _ = &parseArrowFunction;
    _ = &parseAsyncArrowFunction;
    _ = &parseLeftHandSideExpression;
    _ = &parseAssignmentExpression;
    _ = &parseAssignmentOperator;
}

// DoWhileStatement[Yield, Await, Return] : do Statement[?Yield, ?Await, ?Return] while ( Expression[+In, ?Yield, ?Await] ) ;
fn parseDoWhileStatement() !?void {
    //
    _ = &parseStatement;
    _ = &parseExpression;
}

// WhileStatement[Yield, Await, Return] : while ( Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
fn parseWhileStatement() !?void {
    //
    _ = &parseExpression;
    _ = &parseStatement;
}

// ForStatement[Yield, Await, Return] : for ( [lookahead ≠ let [] Expression[~In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
// ForStatement[Yield, Await, Return] : for ( var VariableDeclarationList[~In, ?Yield, ?Await] ; Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
// ForStatement[Yield, Await, Return] : for ( LexicalDeclaration[~In, ?Yield, ?Await] Expression[+In, ?Yield, ?Await]? ; Expression[+In, ?Yield, ?Await]? ) Statement[?Yield, ?Await, ?Return]
fn parseForStatement() !?void {
    //
    _ = &parseExpression;
    _ = &parseStatement;
    _ = &parseVariableDeclarationList;
    _ = &parseLexicalDeclaration;
}

// ForInOfStatement[Yield, Await, Return] : for ( [lookahead ≠ let [] LeftHandSideExpression[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : for ( var ForBinding[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : for ( ForDeclaration[?Yield, ?Await] in Expression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : for ( [lookahead ∉ { let, async of }] LeftHandSideExpression[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : for ( var ForBinding[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : for ( ForDeclaration[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : [+Await] for await ( [lookahead ≠ let] LeftHandSideExpression[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : [+Await] for await ( var ForBinding[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
// ForInOfStatement[Yield, Await, Return] : [+Await] for await ( ForDeclaration[?Yield, ?Await] of AssignmentExpression[+In, ?Yield, ?Await] ) Statement[?Yield, ?Await, ?Return]
fn parseForInOfStatement() !?void {
    //
    _ = &parseLeftHandSideExpression;
    _ = &parseExpression;
    _ = &parseStatement;
    _ = &parseForBinding;
    _ = &parseForDeclaration;
    _ = &parseAssignmentExpression;
}

// CaseBlock[Yield, Await, Return] : { CaseClauses[?Yield, ?Await, ?Return]? }
// CaseBlock[Yield, Await, Return] : { CaseClauses[?Yield, ?Await, ?Return]? DefaultClause[?Yield, ?Await, ?Return] CaseClauses[?Yield, ?Await, ?Return]? }
fn parseCaseBlock() !?void {
    //
    _ = &parseCaseClauses;
    _ = &parseDefaultClause;
}

// Identifier : IdentifierName but not ReservedWord
fn parseIdentifier() !?void {
    //
    _ = &parseIdentifierName;
    _ = &parseReservedWord;
}

// CatchParameter[Yield, Await] : BindingIdentifier[?Yield, ?Await]
// CatchParameter[Yield, Await] : BindingPattern[?Yield, ?Await]
fn parseCatchParameter() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
}

// FormalParameters[Yield, Await] : [empty]
// FormalParameters[Yield, Await] : FunctionRestParameter[?Yield, ?Await]
// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await]
// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await] ,
// FormalParameters[Yield, Await] : FormalParameterList[?Yield, ?Await] , FunctionRestParameter[?Yield, ?Await]
fn parseFormalParameters() !?void {
    //
    _ = &parseFunctionRestParameter;
    _ = &parseFormalParameterList;
}

// FunctionBody[Yield, Await] : FunctionStatementList[?Yield, ?Await]
fn parseFunctionBody() !?void {
    //
    _ = &parseFunctionStatementList;
}

// GeneratorBody : FunctionBody[+Yield, ~Await]
fn parseGeneratorBody() !?void {
    //
    _ = &parseFunctionBody;
}

// AsyncFunctionBody : FunctionBody[~Yield, +Await]
fn parseAsyncFunctionBody() !?void {
    //
    _ = &parseFunctionBody;
}

// AsyncGeneratorBody : FunctionBody[+Yield, +Await]
fn parseAsyncGeneratorBody() !?void {
    //
    _ = &parseFunctionBody;
}

// ClassHeritage[Yield, Await] : extends LeftHandSideExpression[?Yield, ?Await]
fn parseClassHeritage() !?void {
    //
    _ = &parseLeftHandSideExpression;
}

// ClassBody[Yield, Await] : ClassElementList[?Yield, ?Await]
fn parseClassBody() !?void {
    //
    _ = &parseClassElementList;
}

// LexicalBinding[In, Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]?
// LexicalBinding[In, Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[?In, ?Yield, ?Await]
fn parseLexicalBinding() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
    _ = &parseInitializer;
}

// BindingPattern[Yield, Await] : ObjectBindingPattern[?Yield, ?Await]
// BindingPattern[Yield, Await] : ArrayBindingPattern[?Yield, ?Await]
fn parseBindingPattern() !?void {
    //
    _ = &parseObjectBindingPattern;
    _ = &parseArrayBindingPattern;
}

// Initializer[In, Yield, Await] : = AssignmentExpression[?In, ?Yield, ?Await]
fn parseInitializer() !?void {
    //
    _ = &parseAssignmentExpression;
}

// ConditionalExpression[In, Yield, Await] : ShortCircuitExpression[?In, ?Yield, ?Await]
// ConditionalExpression[In, Yield, Await] : ShortCircuitExpression[?In, ?Yield, ?Await] ? AssignmentExpression[+In, ?Yield, ?Await] : AssignmentExpression[?In, ?Yield, ?Await]
fn parseConditionalExpression() !?void {
    //
    _ = &parseShortCircuitExpression;
    _ = &parseAssignmentExpression;
}

// YieldExpression[In, Await] : yield
// YieldExpression[In, Await] : yield [no LineTerminator here] AssignmentExpression[?In, +Yield, ?Await]
// YieldExpression[In, Await] : yield [no LineTerminator here] * AssignmentExpression[?In, +Yield, ?Await]
fn parseYieldExpression() !?void {
    //
    _ = &parseAssignmentExpression;
}

// ArrowFunction[In, Yield, Await] : ArrowParameters[?Yield, ?Await] [no LineTerminator here] => ConciseBody[?In]
fn parseArrowFunction() !?void {
    //
    _ = &parseArrowParameters;
    _ = &parseConciseBody;
}

// AsyncArrowFunction[In, Yield, Await] : async [no LineTerminator here] AsyncArrowBindingIdentifier[?Yield] [no LineTerminator here] => AsyncConciseBody[?In]
// AsyncArrowFunction[In, Yield, Await] : CoverCallExpressionAndAsyncArrowHead[?Yield, ?Await] [no LineTerminator here] => AsyncConciseBody[?In]
fn parseAsyncArrowFunction() !?void {
    //
    _ = &parseAsyncArrowBindingIdentifier;
    _ = &parseCoverCallExpressionAndAsyncArrowHead;
    _ = &parseAsyncConciseBody;
}

// LeftHandSideExpression[Yield, Await] : NewExpression[?Yield, ?Await]
// LeftHandSideExpression[Yield, Await] : CallExpression[?Yield, ?Await]
// LeftHandSideExpression[Yield, Await] : OptionalExpression[?Yield, ?Await]
fn parseLeftHandSideExpression() !?void {
    //
    _ = &parseNewExpression;
    _ = &parseCallExpression;
    _ = &parseOptionalExpression;
}

//  AssignmentOperator : one of
// *= /= %= += -= <<= >>= >>>= &= ^= |= **=
fn parseAssignmentOperator() !?void {
    //
}

// ForBinding[Yield, Await] : BindingIdentifier[?Yield, ?Await]
// ForBinding[Yield, Await] : BindingPattern[?Yield, ?Await]
fn parseForBinding() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
}

// ForDeclaration[Yield, Await] : LetOrConst ForBinding[?Yield, ?Await]
fn parseForDeclaration() !?void {
    //
    _ = &parseLetOrConst;
    _ = &parseForBinding;
}

// CaseClauses[Yield, Await, Return] : CaseClause[?Yield, ?Await, ?Return]
// CaseClauses[Yield, Await, Return] : CaseClauses[?Yield, ?Await, ?Return] CaseClause[?Yield, ?Await, ?Return]
fn parseCaseClauses() !?void {
    //
    _ = &parseCaseClause;
}

// DefaultClause[Yield, Await, Return] : default : StatementList[?Yield, ?Await, ?Return]?
fn parseDefaultClause() !?void {
    //
    _ = &parseStatementList;
}

// IdentifierName :: IdentifierStart
// IdentifierName :: IdentifierName IdentifierPart
fn parseIdentifierName() !?void {
    //
    _ = &parseIdentifierStart;
    _ = &parseIdentifierName;
    _ = &parseIdentifierPart;
}

//  ReservedWord :: one of
// await break case catch class const continue debugger default delete do else enum export extends false finally for function if import in instanceof new null return super switch this throw true try typeof var void while with yield
fn parseReservedWord() !?void {
    //
}

// FunctionRestParameter[Yield, Await] : BindingRestElement[?Yield, ?Await]
fn parseFunctionRestParameter() !?void {
    //
    _ = &parseBindingRestElement;
}

// FormalParameterList[Yield, Await] : FormalParameter[?Yield, ?Await]
// FormalParameterList[Yield, Await] : FormalParameterList[?Yield, ?Await] , FormalParameter[?Yield, ?Await]
fn parseFormalParameterList() !?void {
    //
    _ = &parseFormalParameter;
}

// FunctionStatementList[Yield, Await] : StatementList[?Yield, ?Await, +Return]?
fn parseFunctionStatementList() !?void {
    //
    _ = &parseStatementList;
}

// ClassElementList[Yield, Await] : ClassElement[?Yield, ?Await]
// ClassElementList[Yield, Await] : ClassElementList[?Yield, ?Await] ClassElement[?Yield, ?Await]
fn parseClassElementList() !?void {
    //
    _ = &parseClassElement;
}

// ObjectBindingPattern[Yield, Await] : { }
// ObjectBindingPattern[Yield, Await] : { BindingRestProperty[?Yield, ?Await] }
// ObjectBindingPattern[Yield, Await] : { BindingPropertyList[?Yield, ?Await] }
// ObjectBindingPattern[Yield, Await] : { BindingPropertyList[?Yield, ?Await] , BindingRestProperty[?Yield, ?Await]? }
fn parseObjectBindingPattern() !?void {
    //
    _ = &parseBindingRestProperty;
    _ = &parseBindingPropertyList;
}

// ArrayBindingPattern[Yield, Await] : [ Elision? BindingRestElement[?Yield, ?Await]? ]
// ArrayBindingPattern[Yield, Await] : [ BindingElementList[?Yield, ?Await] ]
// ArrayBindingPattern[Yield, Await] : [ BindingElementList[?Yield, ?Await] , Elision? BindingRestElement[?Yield, ?Await]? ]
fn parseArrayBindingPattern() !?void {
    //
    _ = &parseElision;
    _ = &parseBindingRestElement;
    _ = &parseBindingElementList;
}

// ShortCircuitExpression[In, Yield, Await] : LogicalORExpression[?In, ?Yield, ?Await]
// ShortCircuitExpression[In, Yield, Await] : CoalesceExpression[?In, ?Yield, ?Await]
fn parseShortCircuitExpression() !?void {
    //
    _ = &parseLogicalORExpression;
    _ = &parseCoalesceExpression;
}

// ArrowParameters[Yield, Await] : BindingIdentifier[?Yield, ?Await]
// ArrowParameters[Yield, Await] : CoverParenthesizedExpressionAndArrowParameterList[?Yield, ?Await]
fn parseArrowParameters() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseCoverParenthesizedExpressionAndArrowParameterList;
}

// ConciseBody[In] : [lookahead ≠ {] ExpressionBody[?In, ~Await]
// ConciseBody[In] : { FunctionBody[~Yield, ~Await] }
fn parseConciseBody() !?void {
    //
    _ = &parseExpressionBody;
    _ = &parseFunctionBody;
}

// AsyncArrowBindingIdentifier[Yield] : BindingIdentifier[?Yield, +Await]
fn parseAsyncArrowBindingIdentifier() !?void {
    //
    _ = &parseBindingIdentifier;
}

// CoverCallExpressionAndAsyncArrowHead[Yield, Await] : MemberExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
fn parseCoverCallExpressionAndAsyncArrowHead() !?void {
    //
    _ = &parseMemberExpression;
    _ = &parseArguments;
}

// AsyncConciseBody[In] : [lookahead ≠ {] ExpressionBody[?In, +Await]
// AsyncConciseBody[In] : { AsyncFunctionBody }
fn parseAsyncConciseBody() !?void {
    //
    _ = &parseExpressionBody;
    _ = &parseAsyncFunctionBody;
}

// NewExpression[Yield, Await] : MemberExpression[?Yield, ?Await]
// NewExpression[Yield, Await] : new NewExpression[?Yield, ?Await]
fn parseNewExpression() !?void {
    //
    _ = &parseMemberExpression;
}

// CallExpression[Yield, Await] : CoverCallExpressionAndAsyncArrowHead[?Yield, ?Await]
// CallExpression[Yield, Await] : SuperCall[?Yield, ?Await]
// CallExpression[Yield, Await] : ImportCall[?Yield, ?Await]
// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . IdentifierName
// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
// CallExpression[Yield, Await] : CallExpression[?Yield, ?Await] . PrivateIdentifier
fn parseCallExpression() !?void {
    //
    _ = &parseCoverCallExpressionAndAsyncArrowHead;
    _ = &parseSuperCall;
    _ = &parseImportCall;
    _ = &parseArguments;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parsePrivateIdentifier;
}

// OptionalExpression[Yield, Await] : MemberExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
// OptionalExpression[Yield, Await] : CallExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
// OptionalExpression[Yield, Await] : OptionalExpression[?Yield, ?Await] OptionalChain[?Yield, ?Await]
fn parseOptionalExpression() !?void {
    //
    _ = &parseMemberExpression;
    _ = &parseCallExpression;
    _ = &parseOptionalChain;
}

// CaseClause[Yield, Await, Return] : case Expression[+In, ?Yield, ?Await] : StatementList[?Yield, ?Await, ?Return]?
fn parseCaseClause() !?void {
    //
    _ = &parseExpression;
    _ = &parseStatementList;
}

// IdentifierStart :: IdentifierStartChar
// IdentifierStart :: \ UnicodeEscapeSequence
fn parseIdentifierStart() !?void {
    //
    _ = &parseIdentifierStartChar;
    _ = &parseUnicodeEscapeSequence;
}

// IdentifierPart :: IdentifierPartChar
// IdentifierPart :: \ UnicodeEscapeSequence
fn parseIdentifierPart() !?void {
    //
    _ = &parseIdentifierPartChar;
    _ = &parseUnicodeEscapeSequence;
}

// BindingRestElement[Yield, Await] : ... BindingIdentifier[?Yield, ?Await]
// BindingRestElement[Yield, Await] : ... BindingPattern[?Yield, ?Await]
fn parseBindingRestElement() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
}

// FormalParameter[Yield, Await] : BindingElement[?Yield, ?Await]
fn parseFormalParameter() !?void {
    //
    _ = &parseBindingElement;
}

// ClassElement[Yield, Await] : MethodDefinition[?Yield, ?Await]
// ClassElement[Yield, Await] : static MethodDefinition[?Yield, ?Await]
// ClassElement[Yield, Await] : FieldDefinition[?Yield, ?Await] ;
// ClassElement[Yield, Await] : static FieldDefinition[?Yield, ?Await] ;
// ClassElement[Yield, Await] : ClassStaticBlock
// ClassElement[Yield, Await] : ;
fn parseClassElement() !?void {
    //
    _ = &parseMethodDefinition;
    _ = &parseFieldDefinition;
    _ = &parseClassStaticBlock;
}

// BindingRestProperty[Yield, Await] : ... BindingIdentifier[?Yield, ?Await]
fn parseBindingRestProperty() !?void {
    //
    _ = &parseBindingIdentifier;
}

// BindingPropertyList[Yield, Await] : BindingProperty[?Yield, ?Await]
// BindingPropertyList[Yield, Await] : BindingPropertyList[?Yield, ?Await] , BindingProperty[?Yield, ?Await]
fn parseBindingPropertyList() !?void {
    //
    _ = &parseBindingProperty;
}

// Elision : ,
// Elision : Elision ,
fn parseElision() !?void {
    //
}

// BindingElementList[Yield, Await] : BindingElisionElement[?Yield, ?Await]
// BindingElementList[Yield, Await] : BindingElementList[?Yield, ?Await] , BindingElisionElement[?Yield, ?Await]
fn parseBindingElementList() !?void {
    //
    _ = &parseBindingElisionElement;
}

// LogicalORExpression[In, Yield, Await] : LogicalANDExpression[?In, ?Yield, ?Await]
// LogicalORExpression[In, Yield, Await] : LogicalORExpression[?In, ?Yield, ?Await] || LogicalANDExpression[?In, ?Yield, ?Await]
fn parseLogicalORExpression() !?void {
    //
    _ = &parseLogicalANDExpression;
}

// CoalesceExpression[In, Yield, Await] : CoalesceExpressionHead[?In, ?Yield, ?Await] ?? BitwiseORExpression[?In, ?Yield, ?Await]
fn parseCoalesceExpression() !?void {
    //
    _ = &parseCoalesceExpressionHead;
    _ = &parseBitwiseORExpression;
}

// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] )
// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , )
// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( )
// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( ... BindingIdentifier[?Yield, ?Await] )
// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( ... BindingPattern[?Yield, ?Await] )
// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , ... BindingIdentifier[?Yield, ?Await] )
// CoverParenthesizedExpressionAndArrowParameterList[Yield, Await] : ( Expression[+In, ?Yield, ?Await] , ... BindingPattern[?Yield, ?Await] )
fn parseCoverParenthesizedExpressionAndArrowParameterList() !?void {
    //
    _ = &parseExpression;
    _ = &parseBindingIdentifier;
    _ = &parseBindingPattern;
}

// ExpressionBody[In, Await] : AssignmentExpression[?In, ~Yield, ?Await]
fn parseExpressionBody() !?void {
    //
    _ = &parseAssignmentExpression;
}

// MemberExpression[Yield, Await] : PrimaryExpression[?Yield, ?Await]
// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . IdentifierName
// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
// MemberExpression[Yield, Await] : SuperProperty[?Yield, ?Await]
// MemberExpression[Yield, Await] : MetaProperty
// MemberExpression[Yield, Await] : new MemberExpression[?Yield, ?Await] Arguments[?Yield, ?Await]
// MemberExpression[Yield, Await] : MemberExpression[?Yield, ?Await] . PrivateIdentifier
fn parseMemberExpression() !?void {
    //
    _ = &parsePrimaryExpression;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parseSuperProperty;
    _ = &parseMetaProperty;
    _ = &parseArguments;
    _ = &parsePrivateIdentifier;
}

// Arguments[Yield, Await] : ( )
// Arguments[Yield, Await] : ( ArgumentList[?Yield, ?Await] )
// Arguments[Yield, Await] : ( ArgumentList[?Yield, ?Await] , )
fn parseArguments() !?void {
    //
    _ = &parseArgumentList;
}

// SuperCall[Yield, Await] : super Arguments[?Yield, ?Await]
fn parseSuperCall() !?void {
    //
    _ = &parseArguments;
}

// ImportCall[Yield, Await] : import ( AssignmentExpression[+In, ?Yield, ?Await] )
fn parseImportCall() !?void {
    //
    _ = &parseAssignmentExpression;
}

// TemplateLiteral[Yield, Await, Tagged] : NoSubstitutionTemplate
// TemplateLiteral[Yield, Await, Tagged] : SubstitutionTemplate[?Yield, ?Await, ?Tagged]
fn parseTemplateLiteral() !?void {
    //
    _ = &parseNoSubstitutionTemplate;
    _ = &parseSubstitutionTemplate;
}

// PrivateIdentifier :: # IdentifierName
fn parsePrivateIdentifier() !?void {
    //
    _ = &parseIdentifierName;
}

// OptionalChain[Yield, Await] : ?. Arguments[?Yield, ?Await]
// OptionalChain[Yield, Await] : ?. [ Expression[+In, ?Yield, ?Await] ]
// OptionalChain[Yield, Await] : ?. IdentifierName
// OptionalChain[Yield, Await] : ?. TemplateLiteral[?Yield, ?Await, +Tagged]
// OptionalChain[Yield, Await] : ?. PrivateIdentifier
// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] Arguments[?Yield, ?Await]
// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] [ Expression[+In, ?Yield, ?Await] ]
// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] . IdentifierName
// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] TemplateLiteral[?Yield, ?Await, +Tagged]
// OptionalChain[Yield, Await] : OptionalChain[?Yield, ?Await] . PrivateIdentifier
// OptionalChain[Yield, Await] : LeftHandSideExpression[Yield, Await] :
// OptionalChain[Yield, Await] : NewExpression[?Yield, ?Await]
// OptionalChain[Yield, Await] : CallExpression[?Yield, ?Await]
// OptionalChain[Yield, Await] : OptionalExpression[?Yield, ?Await]
fn parseOptionalChain() !?void {
    //
    _ = &parseArguments;
    _ = &parseExpression;
    _ = &parseIdentifierName;
    _ = &parseTemplateLiteral;
    _ = &parsePrivateIdentifier;
    _ = &parseLeftHandSideExpression;
    _ = &parseNewExpression;
    _ = &parseCallExpression;
    _ = &parseOptionalExpression;
}

// IdentifierStartChar :: UnicodeIDStart
// IdentifierStartChar :: $
// IdentifierStartChar :: _
fn parseIdentifierStartChar() !?void {
    //
    _ = &parseUnicodeIDStart;
}

// UnicodeEscapeSequence :: u Hex4Digits
// UnicodeEscapeSequence :: u{ CodePoint }
fn parseUnicodeEscapeSequence() !?void {
    //
    _ = &parseHex4Digits;
    _ = &parseCodePoint;
}

// IdentifierPartChar :: UnicodeIDContinue
// IdentifierPartChar :: $
// IdentifierPartChar :: <ZWNJ>
// IdentifierPartChar :: <ZWJ>
fn parseIdentifierPartChar() !?void {
    //
    _ = &parseUnicodeIDContinue;
}

// BindingElement[Yield, Await] : SingleNameBinding[?Yield, ?Await]
// BindingElement[Yield, Await] : BindingPattern[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseBindingElement() !?void {
    //
    _ = &parseSingleNameBinding;
    _ = &parseBindingPattern;
    _ = &parseInitializer;
}

// MethodDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
// MethodDefinition[Yield, Await] : GeneratorMethod[?Yield, ?Await]
// MethodDefinition[Yield, Await] : AsyncMethod[?Yield, ?Await]
// MethodDefinition[Yield, Await] : AsyncGeneratorMethod[?Yield, ?Await]
// MethodDefinition[Yield, Await] : get ClassElementName[?Yield, ?Await] ( ) { FunctionBody[~Yield, ~Await] }
// MethodDefinition[Yield, Await] : set ClassElementName[?Yield, ?Await] ( PropertySetParameterList ) { FunctionBody[~Yield, ~Await] }
fn parseMethodDefinition() !?void {
    //
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseFunctionBody;
    _ = &parseGeneratorMethod;
    _ = &parseAsyncMethod;
    _ = &parseAsyncGeneratorMethod;
    _ = &parsePropertySetParameterList;
}

// FieldDefinition[Yield, Await] : ClassElementName[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseFieldDefinition() !?void {
    //
    _ = &parseClassElementName;
    _ = &parseInitializer;
}

// ClassStaticBlock : static { ClassStaticBlockBody }
fn parseClassStaticBlock() !?void {
    //
    _ = &parseClassStaticBlockBody;
}

// BindingProperty[Yield, Await] : SingleNameBinding[?Yield, ?Await]
// BindingProperty[Yield, Await] : PropertyName[?Yield, ?Await] : BindingElement[?Yield, ?Await]
fn parseBindingProperty() !?void {
    //
    _ = &parseSingleNameBinding;
    _ = &parsePropertyName;
    _ = &parseBindingElement;
}

// BindingElisionElement[Yield, Await] : Elision? BindingElement[?Yield, ?Await]
fn parseBindingElisionElement() !?void {
    //
    _ = &parseElision;
    _ = &parseBindingElement;
}

// LogicalANDExpression[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await]
// LogicalANDExpression[In, Yield, Await] : LogicalANDExpression[?In, ?Yield, ?Await] && BitwiseORExpression[?In, ?Yield, ?Await]
fn parseLogicalANDExpression() !?void {
    //
    _ = &parseBitwiseORExpression;
}

// CoalesceExpressionHead[In, Yield, Await] : CoalesceExpression[?In, ?Yield, ?Await]
// CoalesceExpressionHead[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await]
fn parseCoalesceExpressionHead() !?void {
    //
    _ = &parseCoalesceExpression;
    _ = &parseBitwiseORExpression;
}

// BitwiseORExpression[In, Yield, Await] : BitwiseXORExpression[?In, ?Yield, ?Await]
// BitwiseORExpression[In, Yield, Await] : BitwiseORExpression[?In, ?Yield, ?Await] | BitwiseXORExpression[?In, ?Yield, ?Await]
fn parseBitwiseORExpression() !?void {
    //
    _ = &parseBitwiseXORExpression;
}

// PrimaryExpression[Yield, Await] : this
// PrimaryExpression[Yield, Await] : IdentifierReference[?Yield, ?Await]
// PrimaryExpression[Yield, Await] : Literal
// PrimaryExpression[Yield, Await] : ArrayLiteral[?Yield, ?Await]
// PrimaryExpression[Yield, Await] : ObjectLiteral[?Yield, ?Await]
// PrimaryExpression[Yield, Await] : FunctionExpression
// PrimaryExpression[Yield, Await] : ClassExpression[?Yield, ?Await]
// PrimaryExpression[Yield, Await] : GeneratorExpression
// PrimaryExpression[Yield, Await] : AsyncFunctionExpression
// PrimaryExpression[Yield, Await] : AsyncGeneratorExpression
// PrimaryExpression[Yield, Await] : RegularExpressionLiteral
// PrimaryExpression[Yield, Await] : TemplateLiteral[?Yield, ?Await, ~Tagged]
// PrimaryExpression[Yield, Await] : CoverParenthesizedExpressionAndArrowParameterList[?Yield, ?Await]
fn parsePrimaryExpression() !?void {
    //
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
}

// SuperProperty[Yield, Await] : super [ Expression[+In, ?Yield, ?Await] ]
// SuperProperty[Yield, Await] : super . IdentifierName
fn parseSuperProperty() !?void {
    //
    _ = &parseExpression;
    _ = &parseIdentifierName;
}

// MetaProperty : NewTarget
// MetaProperty : ImportMeta
fn parseMetaProperty() !?void {
    //
    _ = &parseNewTarget;
    _ = &parseImportMeta;
}

// ArgumentList[Yield, Await] : AssignmentExpression[+In, ?Yield, ?Await]
// ArgumentList[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
// ArgumentList[Yield, Await] : ArgumentList[?Yield, ?Await] , AssignmentExpression[+In, ?Yield, ?Await]
// ArgumentList[Yield, Await] : ArgumentList[?Yield, ?Await] , ... AssignmentExpression[+In, ?Yield, ?Await]
fn parseArgumentList() !?void {
    //
    _ = &parseAssignmentExpression;
}

// NoSubstitutionTemplate :: ` TemplateCharacters? `
fn parseNoSubstitutionTemplate() !?void {
    //
    _ = &parseTemplateCharacters;
}

// SubstitutionTemplate[Yield, Await, Tagged] : TemplateHead Expression[+In, ?Yield, ?Await] TemplateSpans[?Yield, ?Await, ?Tagged]
fn parseSubstitutionTemplate() !?void {
    //
    _ = &parseTemplateHead;
    _ = &parseExpression;
    _ = &parseTemplateSpans;
}

//  UnicodeIDStart ::
// any Unicode code point with the Unicode property “ID_Start”
fn parseUnicodeIDStart() !?void {
    //
}

// Hex4Digits :: HexDigit HexDigit HexDigit HexDigit
fn parseHex4Digits() !?void {
    //
    _ = &parseHexDigit;
}

//  CodePoint ::
// HexDigits[~Sep] but only if MV of HexDigits ≤ 0x10FFFF
fn parseCodePoint() !?void {
    //
}

//  UnicodeIDContinue ::
// any Unicode code point with the Unicode property “ID_Continue”
fn parseUnicodeIDContinue() !?void {
    //
}

// SingleNameBinding[Yield, Await] : BindingIdentifier[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]?
fn parseSingleNameBinding() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseInitializer;
}

// ClassElementName[Yield, Await] : PropertyName[?Yield, ?Await]
// ClassElementName[Yield, Await] : PrivateIdentifier
fn parseClassElementName() !?void {
    //
    _ = &parsePropertyName;
    _ = &parsePrivateIdentifier;
}

// UniqueFormalParameters[Yield, Await] : FormalParameters[?Yield, ?Await]
fn parseUniqueFormalParameters() !?void {
    //
    _ = &parseFormalParameters;
}

// GeneratorMethod[Yield, Await] : * ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorMethod() !?void {
    //
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseGeneratorBody;
}

// AsyncMethod[Yield, Await] : async [no LineTerminator here] ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncMethod() !?void {
    //
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseAsyncFunctionBody;
}

// AsyncGeneratorMethod[Yield, Await] : async [no LineTerminator here] * ClassElementName[?Yield, ?Await] ( UniqueFormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorMethod() !?void {
    //
    _ = &parseClassElementName;
    _ = &parseUniqueFormalParameters;
    _ = &parseAsyncGeneratorBody;
}

// PropertySetParameterList : FormalParameter[~Yield, ~Await]
fn parsePropertySetParameterList() !?void {
    //
    _ = &parseFormalParameter;
}

// ClassStaticBlockBody : ClassStaticBlockStatementList
fn parseClassStaticBlockBody() !?void {
    //
    _ = &parseClassStaticBlockStatementList;
}

// PropertyName[Yield, Await] : LiteralPropertyName
// PropertyName[Yield, Await] : ComputedPropertyName[?Yield, ?Await]
fn parsePropertyName() !?void {
    //
    _ = &parseLiteralPropertyName;
    _ = &parseComputedPropertyName;
}

// BitwiseXORExpression[In, Yield, Await] : BitwiseANDExpression[?In, ?Yield, ?Await]
// BitwiseXORExpression[In, Yield, Await] : BitwiseXORExpression[?In, ?Yield, ?Await] ^ BitwiseANDExpression[?In, ?Yield, ?Await]
fn parseBitwiseXORExpression() !?void {
    //
    _ = &parseBitwiseANDExpression;
}

// IdentifierReference[Yield, Await] : Identifier
// IdentifierReference[Yield, Await] : [~Yield] yield
// IdentifierReference[Yield, Await] : [~Await] await
fn parseIdentifierReference() !?void {
    //
    _ = &parseIdentifier;
}

// Literal : NullLiteral
// Literal : BooleanLiteral
// Literal : NumericLiteral
// Literal : StringLiteral
fn parseLiteral() !?void {
    //
    _ = &parseNullLiteral;
    _ = &parseBooleanLiteral;
    _ = &parseNumericLiteral;
    _ = &parseStringLiteral;
}

// ArrayLiteral[Yield, Await] : [ Elision? ]
// ArrayLiteral[Yield, Await] : [ ElementList[?Yield, ?Await] ]
// ArrayLiteral[Yield, Await] : [ ElementList[?Yield, ?Await] , Elision? ]
fn parseArrayLiteral() !?void {
    //
    _ = &parseElision;
    _ = &parseElementList;
}

// ObjectLiteral[Yield, Await] : { }
// ObjectLiteral[Yield, Await] : { PropertyDefinitionList[?Yield, ?Await] }
// ObjectLiteral[Yield, Await] : { PropertyDefinitionList[?Yield, ?Await] , }
fn parseObjectLiteral() !?void {
    //
    _ = &parsePropertyDefinitionList;
}

// FunctionExpression : function BindingIdentifier[~Yield, ~Await]? ( FormalParameters[~Yield, ~Await] ) { FunctionBody[~Yield, ~Await] }
fn parseFunctionExpression() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseFunctionBody;
}

// ClassExpression[Yield, Await] : class BindingIdentifier[?Yield, ?Await]? ClassTail[?Yield, ?Await]
fn parseClassExpression() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseClassTail;
}

// GeneratorExpression : function * BindingIdentifier[+Yield, ~Await]? ( FormalParameters[+Yield, ~Await] ) { GeneratorBody }
fn parseGeneratorExpression() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseGeneratorBody;
}

// AsyncFunctionExpression : async [no LineTerminator here] function BindingIdentifier[~Yield, +Await]? ( FormalParameters[~Yield, +Await] ) { AsyncFunctionBody }
fn parseAsyncFunctionExpression() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncFunctionBody;
}

// AsyncGeneratorExpression : async [no LineTerminator here] function * BindingIdentifier[+Yield, +Await]? ( FormalParameters[+Yield, +Await] ) { AsyncGeneratorBody }
fn parseAsyncGeneratorExpression() !?void {
    //
    _ = &parseBindingIdentifier;
    _ = &parseFormalParameters;
    _ = &parseAsyncGeneratorBody;
}

// RegularExpressionLiteral :: / RegularExpressionBody / RegularExpressionFlags
fn parseRegularExpressionLiteral() !?void {
    //
    _ = &parseRegularExpressionBody;
    _ = &parseRegularExpressionFlags;
}

// NewTarget : new . target
fn parseNewTarget() !?void {
    //
}

// ImportMeta : import . meta
fn parseImportMeta() !?void {
    //
}

// TemplateCharacters :: TemplateCharacter TemplateCharacters?
fn parseTemplateCharacters() !?void {
    //
    _ = &parseTemplateCharacter;
}

// TemplateHead :: ` TemplateCharacters? ${
fn parseTemplateHead() !?void {
    //
}

// TemplateSpans[Yield, Await, Tagged] : TemplateTail
// TemplateSpans[Yield, Await, Tagged] : TemplateMiddleList[?Yield, ?Await, ?Tagged] TemplateTail
fn parseTemplateSpans() !?void {
    //
    _ = &parseTemplateTail;
    _ = &parseTemplateMiddleList;
}

//  HexDigit :: one of
// 0 1 2 3 4 5 6 7 8 9 a b c d e f A B C D E F
fn parseHexDigit() !?void {
    //
}

// ClassStaticBlockStatementList : StatementList[~Yield, +Await, ~Return]?
fn parseClassStaticBlockStatementList() !?void {
    //
    _ = &parseStatementList;
}

// LiteralPropertyName : IdentifierName
// LiteralPropertyName : StringLiteral
// LiteralPropertyName : NumericLiteral
fn parseLiteralPropertyName() !?void {
    //
    _ = &parseIdentifierName;
    _ = &parseStringLiteral;
    _ = &parseNumericLiteral;
}

// ComputedPropertyName[Yield, Await] : [ AssignmentExpression[+In, ?Yield, ?Await] ]
fn parseComputedPropertyName() !?void {
    //
    _ = &parseAssignmentExpression;
}

// BitwiseANDExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await]
// BitwiseANDExpression[In, Yield, Await] : BitwiseANDExpression[?In, ?Yield, ?Await] & EqualityExpression[?In, ?Yield, ?Await]
fn parseBitwiseANDExpression() !?void {
    //
    _ = &parseEqualityExpression;
}

// NullLiteral :: null
fn parseNullLiteral() !?void {
    //
}

// BooleanLiteral :: true
// BooleanLiteral :: false
fn parseBooleanLiteral() !?void {
    //
}

// NumericLiteral :: DecimalLiteral
// NumericLiteral :: DecimalBigIntegerLiteral
// NumericLiteral :: NonDecimalIntegerLiteral[+Sep]
// NumericLiteral :: NonDecimalIntegerLiteral[+Sep] BigIntLiteralSuffix
// NumericLiteral :: LegacyOctalIntegerLiteral
fn parseNumericLiteral() !?void {
    //
    _ = &parseDecimalLiteral;
    _ = &parseDecimalBigIntegerLiteral;
    _ = &parseNonDecimalIntegerLiteral;
    _ = &parseBigIntLiteralSuffix;
}

// StringLiteral :: " DoubleStringCharacters? "
// StringLiteral :: ' SingleStringCharacters? '
fn parseStringLiteral() !?void {
    //
    _ = &parseDoubleStringCharacters;
    _ = &parseSingleStringCharacters;
}

// ElementList[Yield, Await] : Elision? AssignmentExpression[+In, ?Yield, ?Await]
// ElementList[Yield, Await] : Elision? SpreadElement[?Yield, ?Await]
// ElementList[Yield, Await] : ElementList[?Yield, ?Await] , Elision? AssignmentExpression[+In, ?Yield, ?Await]
// ElementList[Yield, Await] : ElementList[?Yield, ?Await] , Elision? SpreadElement[?Yield, ?Await]
fn parseElementList() !?void {
    //
    _ = &parseElision;
    _ = &parseAssignmentExpression;
    _ = &parseSpreadElement;
}

// PropertyDefinitionList[Yield, Await] : PropertyDefinition[?Yield, ?Await]
// PropertyDefinitionList[Yield, Await] : PropertyDefinitionList[?Yield, ?Await] , PropertyDefinition[?Yield, ?Await]
fn parsePropertyDefinitionList() !?void {
    //
    _ = &parsePropertyDefinition;
}

// RegularExpressionBody :: RegularExpressionFirstChar RegularExpressionChars
fn parseRegularExpressionBody() !?void {
    //
    _ = &parseRegularExpressionFirstChar;
    _ = &parseRegularExpressionChars;
}

// RegularExpressionFlags :: [empty]
// RegularExpressionFlags :: RegularExpressionFlags IdentifierPartChar
fn parseRegularExpressionFlags() !?void {
    //
    _ = &parseIdentifierPartChar;
}

// TemplateCharacter :: $ [lookahead ≠ {]
// TemplateCharacter :: \ TemplateEscapeSequence
// TemplateCharacter :: \ NotEscapeSequence
// TemplateCharacter :: LineContinuation
// TemplateCharacter :: LineTerminatorSequence
// TemplateCharacter :: SourceCharacter but not one of ` or \ or $ or LineTerminator
fn parseTemplateCharacter() !?void {
    //
    _ = &parseTemplateEscapeSequence;
    _ = &parseNotEscapeSequence;
    _ = &parseLineContinuation;
    _ = &parseLineTerminatorSequence;
    _ = &parseSourceCharacter;
}

// TemplateTail :: } TemplateCharacters? `
fn parseTemplateTail() !?void {
    //
    _ = &parseTemplateCharacters;
}

// TemplateMiddleList[Yield, Await, Tagged] : TemplateMiddle Expression[+In, ?Yield, ?Await]
// TemplateMiddleList[Yield, Await, Tagged] : TemplateMiddleList[?Yield, ?Await, ?Tagged] TemplateMiddle Expression[+In, ?Yield, ?Await]
fn parseTemplateMiddleList() !?void {
    //
    _ = &parseTemplateMiddle;
    _ = &parseExpression;
}

// EqualityExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await]
// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] == RelationalExpression[?In, ?Yield, ?Await]
// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] != RelationalExpression[?In, ?Yield, ?Await]
// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] === RelationalExpression[?In, ?Yield, ?Await]
// EqualityExpression[In, Yield, Await] : EqualityExpression[?In, ?Yield, ?Await] !== RelationalExpression[?In, ?Yield, ?Await]
fn parseEqualityExpression() !?void {
    //
    _ = &parseRelationalExpression;
}

// DecimalLiteral :: DecimalIntegerLiteral . DecimalDigits[+Sep]? ExponentPart[+Sep]?
// DecimalLiteral :: . DecimalDigits[+Sep] ExponentPart[+Sep]?
// DecimalLiteral :: DecimalIntegerLiteral ExponentPart[+Sep]?
fn parseDecimalLiteral() !?void {
    //
    _ = &parseDecimalIntegerLiteral;
    _ = &parseDecimalDigits;
    _ = &parseExponentPart;
}

// DecimalBigIntegerLiteral :: 0 BigIntLiteralSuffix
// DecimalBigIntegerLiteral :: NonZeroDigit DecimalDigits[+Sep]? BigIntLiteralSuffix
// DecimalBigIntegerLiteral :: NonZeroDigit NumericLiteralSeparator DecimalDigits[+Sep] BigIntLiteralSuffix
fn parseDecimalBigIntegerLiteral() !?void {
    //
    _ = &parseBigIntLiteralSuffix;
    _ = &parseNonZeroDigit;
    _ = &parseDecimalDigits;
    _ = &parseNumericLiteralSeparator;
}

// NonDecimalIntegerLiteral[Sep] :: BinaryIntegerLiteral[?Sep]
// NonDecimalIntegerLiteral[Sep] :: OctalIntegerLiteral[?Sep]
// NonDecimalIntegerLiteral[Sep] :: HexIntegerLiteral[?Sep]
fn parseNonDecimalIntegerLiteral() !?void {
    //
    _ = &parseBinaryIntegerLiteral;
    _ = &parseOctalIntegerLiteral;
    _ = &parseHexIntegerLiteral;
}

// BigIntLiteralSuffix :: n
fn parseBigIntLiteralSuffix() !?void {
    //
}

// DoubleStringCharacters :: DoubleStringCharacter DoubleStringCharacters?
fn parseDoubleStringCharacters() !?void {
    //
    _ = &parseDoubleStringCharacter;
}

// SingleStringCharacters :: SingleStringCharacter SingleStringCharacters?
fn parseSingleStringCharacters() !?void {
    //
    _ = &parseSingleStringCharacter;
}

// SpreadElement[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
fn parseSpreadElement() !?void {
    //
    _ = &parseAssignmentExpression;
}

// PropertyDefinition[Yield, Await] : IdentifierReference[?Yield, ?Await]
// PropertyDefinition[Yield, Await] : CoverInitializedName[?Yield, ?Await]
// PropertyDefinition[Yield, Await] : PropertyName[?Yield, ?Await] : AssignmentExpression[+In, ?Yield, ?Await]
// PropertyDefinition[Yield, Await] : MethodDefinition[?Yield, ?Await]
// PropertyDefinition[Yield, Await] : ... AssignmentExpression[+In, ?Yield, ?Await]
fn parsePropertyDefinition() !?void {
    //
    _ = &parseIdentifierReference;
    _ = &parseCoverInitializedName;
    _ = &parsePropertyName;
    _ = &parseAssignmentExpression;
    _ = &parseMethodDefinition;
}

// RegularExpressionFirstChar :: RegularExpressionNonTerminator but not one of * or \ or / or [
// RegularExpressionFirstChar :: RegularExpressionBackslashSequence
// RegularExpressionFirstChar :: RegularExpressionClass
fn parseRegularExpressionFirstChar() !?void {
    //
    _ = &parseRegularExpressionNonTerminator;
    _ = &parseRegularExpressionBackslashSequence;
    _ = &parseRegularExpressionClass;
}

// RegularExpressionChars :: [empty]
// RegularExpressionChars :: RegularExpressionChars RegularExpressionChar
fn parseRegularExpressionChars() !?void {
    //
    _ = &parseRegularExpressionChar;
}

// TemplateEscapeSequence :: CharacterEscapeSequence
// TemplateEscapeSequence :: 0 [lookahead ∉ DecimalDigit]
// TemplateEscapeSequence :: HexEscapeSequence
// TemplateEscapeSequence :: UnicodeEscapeSequence
fn parseTemplateEscapeSequence() !?void {
    //
    _ = &parseCharacterEscapeSequence;
    _ = &parseDecimalDigit;
    _ = &parseHexEscapeSequence;
    _ = &parseUnicodeEscapeSequence;
}

// NotEscapeSequence :: 0 DecimalDigit
// NotEscapeSequence :: DecimalDigit but not 0
// NotEscapeSequence :: x [lookahead ∉ HexDigit]
// NotEscapeSequence :: x HexDigit [lookahead ∉ HexDigit]
// NotEscapeSequence :: u [lookahead ∉ HexDigit] [lookahead ≠ {]
// NotEscapeSequence :: u HexDigit [lookahead ∉ HexDigit]
// NotEscapeSequence :: u HexDigit HexDigit [lookahead ∉ HexDigit]
// NotEscapeSequence :: u HexDigit HexDigit HexDigit [lookahead ∉ HexDigit]
// NotEscapeSequence :: u { [lookahead ∉ HexDigit]
// NotEscapeSequence :: u { NotCodePoint [lookahead ∉ HexDigit]
// NotEscapeSequence :: u { CodePoint [lookahead ∉ HexDigit] [lookahead ≠ }]
fn parseNotEscapeSequence() !?void {
    //
    _ = &parseDecimalDigit;
    _ = &parseHexDigit;
    _ = &parseNotCodePoint;
    _ = &parseCodePoint;
}

// LineContinuation :: \ LineTerminatorSequence
fn parseLineContinuation() !?void {
    //
    _ = &parseLineTerminatorSequence;
}

// LineTerminatorSequence :: <LF>
// LineTerminatorSequence :: <CR> [lookahead ≠ <LF>]
// LineTerminatorSequence :: <LS>
// LineTerminatorSequence :: <PS>
// LineTerminatorSequence :: <CR> <LF>
fn parseLineTerminatorSequence() !?void {
    //
}

//  SourceCharacter ::
// any Unicode code point
fn parseSourceCharacter() !?void {
    //
}

// TemplateMiddle :: } TemplateCharacters? ${
fn parseTemplateMiddle() !?void {
    //
    _ = &parseTemplateCharacters;
}

// RelationalExpression[In, Yield, Await] : ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] < ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] > ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] <= ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] >= ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : RelationalExpression[?In, ?Yield, ?Await] instanceof ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : [+In] RelationalExpression[+In, ?Yield, ?Await] in ShiftExpression[?Yield, ?Await]
// RelationalExpression[In, Yield, Await] : [+In] PrivateIdentifier in ShiftExpression[?Yield, ?Await]
fn parseRelationalExpression() !?void {
    //
    _ = &parseShiftExpression;
    _ = &parsePrivateIdentifier;
}

// DecimalIntegerLiteral :: 0
// DecimalIntegerLiteral :: NonZeroDigit
// DecimalIntegerLiteral :: NonZeroDigit NumericLiteralSeparator? DecimalDigits[+Sep]
// DecimalIntegerLiteral :: NonOctalDecimalIntegerLiteral
fn parseDecimalIntegerLiteral() !?void {
    //
    _ = &parseNonZeroDigit;
    _ = &parseNumericLiteralSeparator;
    _ = &parseDecimalDigits;
    _ = &parseNonOctalDecimalIntegerLiteral;
}

// DecimalDigits[Sep] :: DecimalDigit
// DecimalDigits[Sep] :: DecimalDigits[?Sep] DecimalDigit
// DecimalDigits[Sep] :: [+Sep] DecimalDigits[+Sep] NumericLiteralSeparator DecimalDigit
fn parseDecimalDigits() !?void {
    //
    _ = &parseDecimalDigit;
    _ = &parseNumericLiteralSeparator;
}

// ExponentPart[Sep] :: ExponentIndicator SignedInteger[?Sep]
fn parseExponentPart() !?void {
    //
    _ = &parseExponentIndicator;
    _ = &parseSignedInteger;
}

//  NonZeroDigit :: one of
// 1 2 3 4 5 6 7 8 9
fn parseNonZeroDigit() !?void {
    //
}

// NumericLiteralSeparator :: _
fn parseNumericLiteralSeparator() !?void {
    //
}

// BinaryIntegerLiteral[Sep] :: 0b BinaryDigits[?Sep]
// BinaryIntegerLiteral[Sep] :: 0B BinaryDigits[?Sep]
fn parseBinaryIntegerLiteral() !?void {
    //
    _ = &parseBinaryDigits;
}

// OctalIntegerLiteral[Sep] :: 0o OctalDigits[?Sep]
// OctalIntegerLiteral[Sep] :: 0O OctalDigits[?Sep]
fn parseOctalIntegerLiteral() !?void {
    //
    _ = &parseOctalDigits;
}

// HexIntegerLiteral[Sep] :: 0x HexDigits[?Sep]
// HexIntegerLiteral[Sep] :: 0X HexDigits[?Sep]
fn parseHexIntegerLiteral() !?void {
    //
    _ = &parseHexDigits;
}

// DoubleStringCharacter :: SourceCharacter but not one of " or \ or LineTerminator
// DoubleStringCharacter :: <LS>
// DoubleStringCharacter :: <PS>
// DoubleStringCharacter :: \ EscapeSequence
// DoubleStringCharacter :: LineContinuation
fn parseDoubleStringCharacter() !?void {
    //
    _ = &parseEscapeSequence;
    _ = &parseLineContinuation;
}

// SingleStringCharacter :: SourceCharacter but not one of ' or \ or LineTerminator
// SingleStringCharacter :: <LS>
// SingleStringCharacter :: <PS>
// SingleStringCharacter :: \ EscapeSequence
// SingleStringCharacter :: LineContinuation
fn parseSingleStringCharacter() !?void {
    //
    _ = &parseEscapeSequence;
    _ = &parseLineContinuation;
}

// CoverInitializedName[Yield, Await] : IdentifierReference[?Yield, ?Await] Initializer[+In, ?Yield, ?Await]
fn parseCoverInitializedName() !?void {
    //
    _ = &parseIdentifierReference;
    _ = &parseInitializer;
}

//  RegularExpressionNonTerminator ::
// SourceCharacter but not LineTerminator
fn parseRegularExpressionNonTerminator() !?void {
    //
}

// RegularExpressionBackslashSequence :: \ RegularExpressionNonTerminator
fn parseRegularExpressionBackslashSequence() !?void {
    //
    _ = &parseRegularExpressionNonTerminator;
}

// RegularExpressionClass :: [ RegularExpressionClassChars ]
fn parseRegularExpressionClass() !?void {
    //
    _ = &parseRegularExpressionClassChars;
}

// RegularExpressionChar :: RegularExpressionNonTerminator but not one of \ or / or [
// RegularExpressionChar :: RegularExpressionBackslashSequence
// RegularExpressionChar :: RegularExpressionClass
fn parseRegularExpressionChar() !?void {
    //
    _ = &parseRegularExpressionNonTerminator;
    _ = &parseRegularExpressionBackslashSequence;
    _ = &parseRegularExpressionClass;
}

// CharacterEscapeSequence :: SingleEscapeCharacter
// CharacterEscapeSequence :: NonEscapeCharacter
fn parseCharacterEscapeSequence() !?void {
    //
    _ = &parseSingleEscapeCharacter;
    _ = &parseNonEscapeCharacter;
}

//  DecimalDigit :: one of
// 0 1 2 3 4 5 6 7 8 9
fn parseDecimalDigit() !?void {
    //
}

// HexEscapeSequence :: x HexDigit HexDigit
fn parseHexEscapeSequence() !?void {
    //
    _ = &parseHexDigit;
}

// NotCodePoint :: HexDigits[~Sep] but only if MV of HexDigits > 0x10FFFF
fn parseNotCodePoint() !?void {
    //
}

// ShiftExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await]
// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] << AdditiveExpression[?Yield, ?Await]
// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] >> AdditiveExpression[?Yield, ?Await]
// ShiftExpression[Yield, Await] : ShiftExpression[?Yield, ?Await] >>> AdditiveExpression[?Yield, ?Await]
fn parseShiftExpression() !?void {
    //
    _ = &parseAdditiveExpression;
}

// NonOctalDecimalIntegerLiteral :: 0 NonOctalDigit
// NonOctalDecimalIntegerLiteral :: LegacyOctalLikeDecimalIntegerLiteral NonOctalDigit
// NonOctalDecimalIntegerLiteral :: NonOctalDecimalIntegerLiteral DecimalDigit
fn parseNonOctalDecimalIntegerLiteral() !?void {
    //
    _ = &parseNonOctalDigit;
    _ = &parseDecimalDigit;
}

//  ExponentIndicator :: one of
// e E
fn parseExponentIndicator() !?void {
    //
}

// SignedInteger[Sep] :: DecimalDigits[?Sep]
// SignedInteger[Sep] :: + DecimalDigits[?Sep]
// SignedInteger[Sep] :: - DecimalDigits[?Sep]
fn parseSignedInteger() !?void {
    //
    _ = &parseDecimalDigits;
}

// BinaryDigits[Sep] :: BinaryDigit
// BinaryDigits[Sep] :: BinaryDigits[?Sep] BinaryDigit
// BinaryDigits[Sep] :: [+Sep] BinaryDigits[+Sep] NumericLiteralSeparator BinaryDigit
fn parseBinaryDigits() !?void {
    //
    _ = &parseBinaryDigit;
    _ = &parseNumericLiteralSeparator;
}

// OctalDigits[Sep] :: OctalDigit
// OctalDigits[Sep] :: OctalDigits[?Sep] OctalDigit
// OctalDigits[Sep] :: [+Sep] OctalDigits[+Sep] NumericLiteralSeparator OctalDigit
fn parseOctalDigits() !?void {
    //
    _ = &parseOctalDigit;
    _ = &parseNumericLiteralSeparator;
}

// HexDigits[Sep] :: HexDigit
// HexDigits[Sep] :: HexDigits[?Sep] HexDigit
// HexDigits[Sep] :: [+Sep] HexDigits[+Sep] NumericLiteralSeparator HexDigit
fn parseHexDigits() !?void {
    //
    _ = &parseHexDigit;
    _ = &parseNumericLiteralSeparator;
}

// EscapeSequence :: CharacterEscapeSequence
// EscapeSequence :: 0 [lookahead ∉ DecimalDigit]
// EscapeSequence :: LegacyOctalEscapeSequence
// EscapeSequence :: NonOctalDecimalEscapeSequence
// EscapeSequence :: HexEscapeSequence
// EscapeSequence :: UnicodeEscapeSequence
fn parseEscapeSequence() !?void {
    //
    _ = &parseCharacterEscapeSequence;
    _ = &parseNonOctalDecimalEscapeSequence;
    _ = &parseHexEscapeSequence;
    _ = &parseUnicodeEscapeSequence;
}

// RegularExpressionClassChars :: [empty]
// RegularExpressionClassChars :: RegularExpressionClassChars RegularExpressionClassChar
fn parseRegularExpressionClassChars() !?void {
    //
    _ = &parseRegularExpressionClassChar;
}

//  SingleEscapeCharacter :: one of
// ' " \ b f n r t v
fn parseSingleEscapeCharacter() !?void {
    //
}

// NonEscapeCharacter :: SourceCharacter but not one of EscapeCharacter or LineTerminator
fn parseNonEscapeCharacter() !?void {
    //
}

// AdditiveExpression[Yield, Await] : MultiplicativeExpression[?Yield, ?Await]
// AdditiveExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await] + MultiplicativeExpression[?Yield, ?Await]
// AdditiveExpression[Yield, Await] : AdditiveExpression[?Yield, ?Await] - MultiplicativeExpression[?Yield, ?Await]
fn parseAdditiveExpression() !?void {
    //
    _ = &parseMultiplicativeExpression;
}

//  NonOctalDigit :: one of
// 8 9
fn parseNonOctalDigit() !?void {
    //
}

//  BinaryDigit :: one of
// 0 1
fn parseBinaryDigit() !?void {
    //
}

//  OctalDigit :: one of
// 0 1 2 3 4 5 6 7
fn parseOctalDigit() !?void {
    //
}

//  NonOctalDecimalEscapeSequence :: one of
// 8 9
fn parseNonOctalDecimalEscapeSequence() !?void {
    //
}

// RegularExpressionClassChar :: RegularExpressionNonTerminator but not one of ] or \
// RegularExpressionClassChar :: RegularExpressionBackslashSequence
fn parseRegularExpressionClassChar() !?void {
    //
    _ = &parseRegularExpressionNonTerminator;
    _ = &parseRegularExpressionBackslashSequence;
}

// MultiplicativeExpression[Yield, Await] : ExponentiationExpression[?Yield, ?Await]
// MultiplicativeExpression[Yield, Await] : MultiplicativeExpression[?Yield, ?Await] MultiplicativeOperator ExponentiationExpression[?Yield, ?Await]
fn parseMultiplicativeExpression() !?void {
    //
    _ = &parseExponentiationExpression;
    _ = &parseMultiplicativeOperator;
}

// ExponentiationExpression[Yield, Await] : UnaryExpression[?Yield, ?Await]
// ExponentiationExpression[Yield, Await] : UpdateExpression[?Yield, ?Await] ** ExponentiationExpression[?Yield, ?Await]
fn parseExponentiationExpression() !?void {
    //
    _ = &parseUnaryExpression;
    _ = &parseUpdateExpression;
}

//  MultiplicativeOperator : one of
// * / %
fn parseMultiplicativeOperator() !?void {
    //
}

// UnaryExpression[Yield, Await] : UpdateExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : delete UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : void UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : typeof UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : + UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : - UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : ~ UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : ! UnaryExpression[?Yield, ?Await]
// UnaryExpression[Yield, Await] : [+Await] AwaitExpression[?Yield]
fn parseUnaryExpression() !?void {
    //
    _ = &parseUpdateExpression;
    _ = &parseAwaitExpression;
}

// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await]
// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await] [no LineTerminator here] ++
// UpdateExpression[Yield, Await] : LeftHandSideExpression[?Yield, ?Await] [no LineTerminator here] --
// UpdateExpression[Yield, Await] : ++ UnaryExpression[?Yield, ?Await]
// UpdateExpression[Yield, Await] : -- UnaryExpression[?Yield, ?Await]
fn parseUpdateExpression() !?void {
    //
    _ = &parseLeftHandSideExpression;
    _ = &parseUnaryExpression;
}

// AwaitExpression[Yield] : await UnaryExpression[?Yield, +Await]
fn parseAwaitExpression() !?void {
    //
    _ = &parseUnaryExpression;
}

// Module : ModuleBody?
fn parseModule() !?void {
    //
    _ = &parseModuleBody;
}

// ModuleBody : ModuleItemList
fn parseModuleBody() !?void {
    //
    _ = &parseModuleItemList;
}

// ModuleItemList : ModuleItem
// ModuleItemList : ModuleItemList ModuleItem
fn parseModuleItemList() !?void {
    //
    _ = &parseModuleItem;
}

// ModuleItem : ImportDeclaration
// ModuleItem : ExportDeclaration
// ModuleItem : StatementListItem[~Yield, +Await, ~Return]
fn parseModuleItem() !?void {
    //
    _ = &parseImportDeclaration;
    _ = &parseExportDeclaration;
    _ = &parseStatementListItem;
}

// ImportDeclaration : import ImportClause FromClause ;
// ImportDeclaration : import ModuleSpecifier ;
fn parseImportDeclaration() !?void {
    //
    _ = &parseImportClause;
    _ = &parseFromClause;
    _ = &parseModuleSpecifier;
}

// ExportDeclaration : export ExportFromClause FromClause ;
// ExportDeclaration : export NamedExports ;
// ExportDeclaration : export VariableStatement[~Yield, +Await]
// ExportDeclaration : export Declaration[~Yield, +Await]
// ExportDeclaration : export default HoistableDeclaration[~Yield, +Await, +Default]
// ExportDeclaration : export default ClassDeclaration[~Yield, +Await, +Default]
// ExportDeclaration : export default [lookahead ∉ { function, async [no LineTerminator here] function, class }] AssignmentExpression[+In, ~Yield, +Await] ;
fn parseExportDeclaration() !?void {
    //
    _ = &parseExportFromClause;
    _ = &parseFromClause;
    _ = &parseVariableStatement;
    _ = &parseDeclaration;
    _ = &parseHoistableDeclaration;
    _ = &parseClassDeclaration;
    _ = &parseAssignmentExpression;
}

// ImportClause : ImportedDefaultBinding
// ImportClause : NameSpaceImport
// ImportClause : NamedImports
// ImportClause : ImportedDefaultBinding , NameSpaceImport
// ImportClause : ImportedDefaultBinding , NamedImports
fn parseImportClause() !?void {
    //
    _ = &parseImportedDefaultBinding;
    _ = &parseNameSpaceImport;
    _ = &parseNamedImports;
}

// FromClause : from ModuleSpecifier
fn parseFromClause() !?void {
    //
    _ = &parseModuleSpecifier;
}

// ModuleSpecifier : StringLiteral
fn parseModuleSpecifier() !?void {
    //
    _ = parseStringLiteral;
}

// ExportFromClause : *
// ExportFromClause : * as ModuleExportName
// ExportFromClause : NamedExports
fn parseExportFromClause() !?void {
    //
    _ = &parseModuleExportName;
    _ = &parseNamedExports;
}

// ImportedDefaultBinding : ImportedBinding
fn parseImportedDefaultBinding() !?void {
    //
    _ = &parseImportedBinding;
}

// NameSpaceImport : * as ImportedBinding
fn parseNameSpaceImport() !?void {
    //
    _ = &parseImportedBinding;
}

// NamedImports : { }
// NamedImports : { ImportsList }
// NamedImports : { ImportsList , }
fn parseNamedImports() !?void {
    //
    _ = &parseImportsList;
}

// ModuleExportName : IdentifierName
// ModuleExportName : StringLiteral
fn parseModuleExportName() !?void {
    //
    _ = &parseIdentifierName;
    _ = &parseStringLiteral;
}

// NamedExports : { }
// NamedExports : { ExportsList }
// NamedExports : { ExportsList , }
fn parseNamedExports() !?void {
    //
}

// ImportedBinding : BindingIdentifier[~Yield, +Await]
fn parseImportedBinding() !?void {
    //
    _ = &parseBindingIdentifier;
}

// ImportsList : ImportSpecifier
// ImportsList : ImportsList , ImportSpecifier
fn parseImportsList() !?void {
    //
    _ = &parseImportSpecifier;
}

// ExportsList : ExportSpecifier
// ExportsList : ExportsList , ExportSpecifier
fn parseExportsList() !?void {
    //
    _ = &parseExportSpecifier;
}

// ImportSpecifier : ImportedBinding
// ImportSpecifier : ModuleExportName as ImportedBinding
fn parseImportSpecifier() !?void {
    //
    _ = &parseImportedBinding;
    _ = &parseModuleExportName;
}

// ExportSpecifier : ModuleExportName
// ExportSpecifier : ModuleExportName as ModuleExportName
fn parseExportSpecifier() !?void {
    //
    _ = &parseModuleExportName;
}
