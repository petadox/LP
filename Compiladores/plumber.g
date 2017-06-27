#header
<<
#include <string>
#include <iostream>
#include <vector>
#include <map>
using namespace std;

// struct to store information about tokens
typedef struct {
  string kind;
  string text;
} Attrib;

// function to fill token information (predeclaration)
void zzcr_attr(Attrib *attr, int type, char *text);

// fields for AST nodes
#define AST_FIELDS string kind; string text;
#include "ast.h"

// macro to create a new AST node (and function predeclaration)
#define zzcr_ast(as,attr,ttype,textt) as=createASTnode(attr,ttype,textt)
AST* createASTnode(Attrib* attr, int ttype, char *textt);
>>

<<
#include <cstdlib>
#include <cmath>

//global structures
AST *root;

typedef struct {
	int length, diameter; //Si es connector length = -1
} dimensions;

typedef struct {
	int size;
	int elem;
	vector<dimensions> tubs;
} props;

map<string, props> vectors;

map<string, dimensions> tuberias;

// function to fill token information
void zzcr_attr(Attrib *attr, int type, char *text) {
    attr->kind = text;
    attr->text = "";
}

// function to create a new AST node
AST* createASTnode(Attrib* attr, int type, char* text) {
  AST* as = new AST;
  as->kind = attr->kind; 
  as->text = attr->text;
  as->right = NULL; 
  as->down = NULL;
  return as;
}

/// create a new "list" AST node with one element
AST* createASTlist(AST *child) {
 AST *as=new AST;
 as->kind="list";
 as->right=NULL;
 as->down=child;
 return as;
}

/// get nth child of a tree. Count starts at 0.
/// if no such child, returns NULL
AST* child(AST *a,int n) {
 AST *c=a->down;
 for (int i=0; c!=NULL && i<n; i++) c=c->right;
 return c;
} 

/// print AST, recursively, with indentation
void ASTPrintIndent(AST *a,string s)
{
  if (a==NULL) return;

  cout<<a->kind;
  if (a->text!="") cout<<"("<<a->text<<")";
  cout<<endl;

  AST *i = a->down;
  while (i!=NULL && i->right!=NULL) {
    cout<<s+"  \\__";
    ASTPrintIndent(i,s+"  |"+string(i->kind.size()+i->text.size(),' '));
    i=i->right;
  }
  
  if (i!=NULL) {
      cout<<s+"  \\__";
      ASTPrintIndent(i,s+"   "+string(i->kind.size()+i->text.size(),' '));
      i=i->right;
  }
}

/// print AST 
void ASTPrint(AST *a)
{
  while (a!=NULL) {
    cout<<" ";
    ASTPrintIndent(a,"");
    a=a->right;
  }
}

dimensions doMerge(AST *a) {	//-1 -1 si no es pot
	dimensions d1,d2,ret;
	ret.diameter = -1;
	ret.length = -1;
	
	if (tuberias.find(a->down->right->kind) == tuberias.end()) {cout << "NO EXISTE EL CONNECTOR: " << a->down->right->kind << endl; return ret; }
	
	int diamC = tuberias[a->down->right->kind].diameter;
	
	if (a->down->kind == "MERGE") d1 = doMerge(a->down);
	else if (tuberias.find(a->down->kind) == tuberias.end()) { cout << "NO EXISTE LA TUBERIA: " << a->down->kind << endl; return ret; }
	else d1 = tuberias[a->down->kind];
	
	if (a->down->right->right->kind == "MERGE") d2 = doMerge(a->down->right->right);
	else if (tuberias.find(a->down->right->right->kind) == tuberias.end()) {cout << "NO EXISTE LA TUBERIA: " << a->down->right->right->kind << endl; return ret; }
	else d2 = tuberias[a->down->right->right->kind];
	
	if (d1.diameter == diamC and diamC == d2.diameter) {
		ret.diameter = diamC;
		ret.length = d1.length + d2.length;
		return ret;
	}
	else {
		cout << "DIAMETRES INCOMPATIBLES" << endl;
		return ret;
	}
}

void borraTuberias(AST *a, string nouElem) {
	tuberias.erase(a->down->right->kind);
	if (a->down->kind == "MERGE") borraTuberias(a->down, nouElem);
	else if (a->down->kind != nouElem) tuberias.erase(a->down->kind);
	
	if (a->down->right->right->kind == "MERGE") borraTuberias(a->down->right->right, nouElem);
	else if (a->down->right->right->kind != nouElem) tuberias.erase(a->down->right->right->kind);
}

void doSplit(AST *a) {
	int diameter = tuberias[a->down->right->right->down->kind].diameter;
	int length = tuberias[a->down->right->right->down->kind].length;
	dimensions d1, d2;
	d1.diameter = diameter; d2.diameter = diameter;
	d1.length = length/2; d2.length = length/2;
	if (length % 2 != 0) ++d2.length;
	if (d1.length != 0) {
		if (tuberias.find(a->down->kind) == tuberias.end()) tuberias.insert(make_pair(a->down->kind,d1));
		else tuberias[a->down->kind] = d1;
	}
	if (d2.length != 0) {
		if (tuberias.find(a->down->right->kind) == tuberias.end()) tuberias.insert(make_pair(a->down->right->kind,d2));
		else tuberias[a->down->right->kind] = d2;
	}
	tuberias.erase(a->down->right->right->down->kind);
}

void creaVector(AST *a) {
	props aux;
	aux.elem = 0;
	aux.size = atoi(a->down->right->down->kind.c_str());
	aux.tubs = vector<dimensions>(aux.size);
	vectors.insert(make_pair(a->down->kind,aux));
}

bool pushTub(AST *a) {
	if (vectors[a->down->kind].elem == vectors[a->down->kind].size) return false;
	else {
		int elem = vectors[a->down->kind].elem;
		vectors[a->down->kind].tubs[elem] = tuberias[a->down->right->kind];
		++vectors[a->down->kind].elem;
	}
	return true;
}

bool popTub(AST *a) {
	if (vectors[a->down->kind].elem == 0) return false;
	else {
		--vectors[a->down->kind].elem;
		int elem = vectors[a->down->kind].elem;
		dimensions d = vectors[a->down->kind].tubs[elem];
		tuberias.insert(make_pair(a->down->right->kind,d));
	}
	return true;
}

void printTubs() {
	cout << endl << "MOSTREM ELS TUBS Y CONNECTORS" << endl;
	map<string,dimensions>::iterator it = tuberias.begin();
	while (it != tuberias.end()) {
		dimensions d = it->second;
		if (d.length == -1) cout << "CONNECTOR " << it->first << " " << d.diameter << endl;
		else cout << "TUBERIA " << it->first << " " << d.length << " " << d.diameter << endl;
		++it;
	}
	cout << endl;
}

void printVectors() {
	cout << "MOSTREM ELS VECTORS" << endl;
	map<string,props>::iterator it = vectors.begin();
	while (it != vectors.end()) {
		cout << it->first << endl;
		props aux = it->second;
		int i = 0;
		while (i < aux.elem) {
			cout << aux.tubs[i].length << " " << aux.tubs[i].diameter << endl;
			++i;
		}
		cout << endl;
		++it;
	}
}

int evaluate(AST *a) {
	if (a == NULL) return 0;
	else if (a->kind == "FULL") {
		if (vectors[a->down->kind].elem == vectors[a->down->kind].size) return 1;
		else return 0;
	}
	else if (a->kind == "EMPTY") {
		if (vectors[a->down->kind].elem == 0) return 1;
		else return 0;
	}
	else if (a->kind == "+") {
		return evaluate(a->down) + evaluate(a->down->right);
	}
	else if (a->kind == "-") {
		return evaluate(a->down) - evaluate(a->down->right);
	}
	else if (a->kind == "*") {
		return evaluate(a->down) * evaluate(a->down->right);
	}
	else if (a->kind == "NOT") {
		if (evaluate(a->down) == 1) return 0;
		else return 1;
	}
	else if (a->kind == "OR"){
		if (evaluate(a->down) == 1 or evaluate(a->down->right) == 1) return 1;
		else return 0;
	}
	else if (a->kind == "AND"){
		if (evaluate(a->down) == 1 and evaluate(a->down->right) == 1) return 1;
		else return 0;
	}
	else if (a->kind == "LENGTH") {
		return tuberias[a->down->kind].length;
	}
	else if (a->kind == "DIAMETER") {
		return tuberias[a->down->kind].diameter;
	}
	else if (a->kind == ">" or a->kind == "<" or a->kind == "=="){
		if (a->down->kind == "LENGTH") {
			if (a->down->right->kind == "LENGTH") {
				if (a->kind == ">" and tuberias[a->down->down->kind].length > tuberias[a->down->right->down->kind].length) return 1;
				else if (a->kind == "<" and tuberias[a->down->down->kind].length < tuberias[a->down->right->down->kind].length) return 1;
				else if (a->kind == "==" and tuberias[a->down->down->kind].length == tuberias[a->down->right->down->kind].length) return 1;
				else return 0;
			}
			else if (a->down->right->kind == "DIAMETER") {
				if (a->kind == ">" and tuberias[a->down->down->kind].length > tuberias[a->down->right->down->kind].diameter) return 1;
				else if (a->kind == "<" and tuberias[a->down->down->kind].length < tuberias[a->down->right->down->kind].diameter) return 1;
				else if (a->kind == "==" and tuberias[a->down->down->kind].length == tuberias[a->down->right->down->kind].diameter) return 1;
				else return 0;
			}
			else {
				if (a->kind == ">" and tuberias[a->down->down->kind].length > atoi(a->down->right->kind.c_str())) return 1;
				else if (a->kind == "<" and tuberias[a->down->down->kind].length < atoi(a->down->right->kind.c_str())) return 1;
				else if (a->kind == "==" and tuberias[a->down->down->kind].length == atoi(a->down->right->kind.c_str())) return 1;
				else return 0;
			}
		}
		else if (a->down->kind == "DIAMETER") {
			if (a->down->right->kind == "LENGTH") {
				if (a->kind == ">" and tuberias[a->down->down->kind].diameter > tuberias[a->down->right->down->kind].length) return 1;
				else if (a->kind == "<" and tuberias[a->down->down->kind].diameter < tuberias[a->down->right->down->kind].length) return 1;
				else if (a->kind == "==" and tuberias[a->down->down->kind].diameter == tuberias[a->down->right->down->kind].length) return 1;
				else return 0;
			}
			else if (a->down->right->kind == "DIAMETER") {
				if (a->kind == ">" and tuberias[a->down->down->kind].diameter > tuberias[a->down->right->down->kind].diameter) return 1;
				else if (a->kind == "<" and tuberias[a->down->down->kind].diameter < tuberias[a->down->right->down->kind].diameter) return 1;
				else if (a->kind == "==" and tuberias[a->down->down->kind].diameter == tuberias[a->down->right->down->kind].diameter) return 1;
				else return 0;
			}
			else {
				if (a->kind == ">" and tuberias[a->down->down->kind].diameter > atoi(a->down->right->kind.c_str())) return 1;
				else if (a->kind == "<" and tuberias[a->down->down->kind].diameter < atoi(a->down->right->kind.c_str())) return 1;
				else if (a->kind == "==" and tuberias[a->down->down->kind].diameter == atoi(a->down->right->kind.c_str())) return 1;
				else return 0;
			}
		}
		else {
			if (a->down->right->kind == "LENGTH") {
				if (a->kind == ">" and atoi(a->down->kind.c_str()) > tuberias[a->down->right->down->kind].length) return 1;
				else if (a->kind == "<" and atoi(a->down->kind.c_str()) < tuberias[a->down->right->down->kind].length) return 1;
				else if (a->kind == "==" and atoi(a->down->kind.c_str()) == tuberias[a->down->right->down->kind].length) return 1;
				else return 0;
			}
			else if (a->down->right->kind == "DIAMETER") {
				if (a->kind == ">" and atoi(a->down->kind.c_str()) > tuberias[a->down->right->down->kind].diameter) return 1;
				else if (a->kind == "<" and atoi(a->down->kind.c_str()) < tuberias[a->down->right->down->kind].diameter) return 1;
				else if (a->kind == "==" and atoi(a->down->kind.c_str()) == tuberias[a->down->right->down->kind].diameter) return 1;
				else return 0;
			}
			else {
				if (a->kind == ">" and atoi(a->down->kind.c_str()) > atoi(a->down->right->kind.c_str())) return 1;
				else if (a->kind == "<" and atoi(a->down->kind.c_str()) < atoi(a->down->right->kind.c_str())) return 1;
				else if (a->kind == "==" and atoi(a->down->kind.c_str()) == atoi(a->down->right->kind.c_str())) return 1;
				else return 0;
			}
		}
	}
	else {
		return atoi(a->kind.c_str());
	}
}

void executeListInstructions(AST *a) {
	if (a==NULL) return;
	else if (a->kind == "list") {
		executeListInstructions(a->down);
	}
	else if (a->kind == "=") {
		if (a->down->right->kind == "TUBE") {
			dimensions d;
			d.length = evaluate(a->down->right->down);
			d.diameter = evaluate(a->down->right->down->right);
			tuberias.insert(make_pair(a->down->kind, d));
		}
		else if (a->down->right->kind == "CONNECTOR") {
			dimensions d;
			d.diameter = evaluate(a->down->right->down);
			d.length = -1;
			tuberias.insert(make_pair(a->down->kind, d));
		}
		else if (a->down->right->kind == "MERGE") {
			dimensions d = doMerge(a->down->right);
			if (d.length == -1) cout << "MERGE INCOMPATIBLE" << endl;
			else {
				if (tuberias.find(a->down->kind) == tuberias.end()) tuberias.insert(make_pair(a->down->kind,d));
				else tuberias[a->down->kind] = d;
				borraTuberias(a->down->right,a->down->kind);
			}
		}
		else if (a->down->right->right != NULL and a->down->right->right->kind == "SPLIT") {
			doSplit(a);
		}
		else if (a->down->right->kind == "TUBEVECTOR") {
			creaVector(a);
		}
		else { //SIMPLE COPY
			if (tuberias.find(a->down->right->kind) != tuberias.end()) {
				dimensions d = tuberias[a->down->right->kind];
				if (tuberias.find(a->down->kind) == tuberias.end()) tuberias.insert(make_pair(a->down->kind,d));
				else tuberias[a->down->kind] = d;
				tuberias.erase(a->down->right->kind);
			}
			else if (vectors.find(a->down->right->kind) != vectors.end()) {
				props p = vectors[a->down->right->kind];
				if (vectors.find(a->down->kind) == vectors.end()) vectors.insert(make_pair(a->down->kind,p));
				else vectors[a->down->kind] = p;
				vectors.erase(a->down->right->kind);
			}
			else cout << "EL TUB, VECTOR O CONNECTOR NO EXISTEIX" << endl;
		}
	}
	else if (a->kind == "WHILE") {
		while (evaluate(a->down)!=0) {
			executeListInstructions(a->down->right);
		}
	}
	else if (a->kind == "DIAMETER") {
		map<string,dimensions>::iterator it = tuberias.find(a->down->kind);
		if (it != tuberias.end()) cout << "DIAMETER(" << a->down->kind << ") = " << tuberias[a->down->kind].diameter << endl;
		else cout << "La tuberia " << a->down->kind << " no existeix" << endl;
	}
	else if (a->kind == "LENGTH") {
		map<string,dimensions>::iterator it = tuberias.find(a->down->kind);
		if (it != tuberias.end()) cout << "LENGTH(" << a->down->kind << ") = " << tuberias[a->down->kind].length << endl;
		else cout << "La tuberia " << a->down->kind << " no existeix" << endl;
	}
	else if (a->kind == "PUSH") {
		if (not pushTub(a)) cout << "Vector ple" << endl;
	}
	else if (a->kind == "POP") {
		if (not popTub(a)) cout << "Vector buit" << endl;
	}
	executeListInstructions(a->right);
}

int main() {
  AST *root = NULL;
  ANTLR(plumber(&root), stdin);
  ASTPrint(root);
  executeListInstructions(root);
  printTubs();
  printVectors();
}
>>

#lexclass START
//...
#token TUBE "TUBE"
#token SPLIT "SPLIT"
#token CONNECTOR "CONNECTOR"
#token MERGE "MERGE"
#token LENGTH "LENGTH"
#token DIAMETER "DIAMETER"
#token WHILE "WHILE"
#token ENDWHILE "ENDWHILE"
#token PUSH "PUSH"
#token POP "POP"
#token TUBEVECTOR "TUBEVECTOR"
#token FULL "FULL"
#token EMPTY "EMPTY"
#token EQUAL "\="
#token BIGGER "\>"
#token SMALLER "\<"
#token SAME "\=="
#token OF "OF"
#token NOT "NOT"
#token OR "OR"
#token AND "AND"
#token PARO "\("
#token PARC "\)"
#token PLUS "\+"
#token MINUS "\-"
#token TIMES "\*"
#token NUM "[0-9]+"
#token ID "[A-Z] ([A-Z]|[0-9])*"
#token SPACE "[\ \n]" << zzskip();>>

plumber: (ops)* <<#0=createASTlist(_sibling);>>;
ops: (startid|isplit|diameter|length|bucle|push|pop|full|empty);
startid: ID EQUAL^ (assig|ID|connector|merge|tubevector);
assig: TUBE^ parella;
parella: retnum retnum;
connector: CONNECTOR^ retnum;
diameter: DIAMETER^ "\("! ID "\)"!;
length: LENGTH^ "\("! ID "\)"!;
merge: MERGE^ (ID|merge) ID (ID|merge);
tubevector: TUBEVECTOR^ OF! retnum;
bucle: WHILE^ condicio cosbucle;
condicio: PARO! cond PARC!;
cosbucle: <<#0=createASTlist(_sibling);>> (ops)+ ENDWHILE!;
cond: icond (OR^ icond)*;
icond: expr (AND^ expr)*; 
expr: (boolcond|(retnum (BIGGER^|SMALLER^|SAME^) retnum))|(PARO! cond PARC!) ;
boolcond: negcond|poscond;
negcond: NOT^ poscond;
poscond: full|empty;
push: PUSH^ ID ID;
pop: POP^ ID ID;
full: FULL^ PARO! ID PARC!;
empty: EMPTY^ PARO! ID PARC!;
isplit: PARO! ID "\,"! ID PARC! EQUAL^ split;
split: SPLIT^ ID;
retnum: exprnum;
exprnum: term ((PLUS^|MINUS^) term)*;
term: (NUM|diameter|length) (TIMES^ (NUM|diameter|length))*;
//...

