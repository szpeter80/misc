# C# Cheat Sheet / Quick Reference

---

## 01 | Command Line

**Check Version:**  ```dotnet version ```

**Create Project:** ```dotnet new project ```

**Run Project:**  ```dotnet <project-dir> [console ...]```

---

## 02 | Simple Data Types

```
byte b = 255;      // size: 1 byte

// ints have u-prefixed unsigned variants
short si  = 300;   // size: 2 bytes
int    i  = 2000;  // size: 4 bytes (32 bits)
long  li  = 20000; // size: 8 bytes (64 bits)

// division ... by int yields whole result,
// by zero - it's a NaN !
int res = 10 / 3;  // gives 3 

float f  = 3.14F;   // size: 4 bytes
double   = 3.14D;   // size: 8 bytes

// does not norm trailing zeroes,
// 1.0M != 1.000M, size: 16 bytes
decimal  = 3.14M;

// size: 1 byte, see sizeof(bool)
bool is_empty = false;  
```

---

## 03 | Arrays


```
// simple 1-dimensional array,
// size can't be part of the def
int[] ia = new int[100]; // init with 'new'

// arrays can be init'ed with values too
// size inferred from the constant expr.
int[] ib = {1, 2, 3};

// 2-dim array, 10 rows and 200 columns
string[,] sa;  sa = new string[10,200];

// get the dimensions of the existing array
sa.Rank  // 2, for the two dimensions
sa.GetLength(0) // returns 10 for the rows
sa.GetLength(1) // returns 200 for the col's

// simple array sort, ascending
// Sort() has many overloads, check them
Array.Sort(ia);

// Clear array elements
Array.Clear(ib, 0, ib.Length());

// Duplicate array
Array.Copy(srcArray, dstArray, no_of_items);
```

---

## 04 | Strings



```
// String is a reference type, like an object 
// so its default value is NULL !

// set to empty string from default NULL
string s = "" 

// A char in C# is a 16 bit (2byte) number,
// a single UTF-16 symbol. UTF-16 encodes 
// Unicode code points 0x0000-0xffff as-is,
// and values beyond that as surrogate pair
// of symbols. Beware, not all code points
// are characters, eg NFD accents 

char ch = '\u03A9'; // Greek capital 'omega'
int i = (int) ch;  // i is now 0x03a9 or 937

// string can be used as array of characters
string s = "Example string";
s[0] == 'E'  // this evaluates to "true"
s[0] = 'F'   // error, can't assign value

// number of char instances (UTF-16 symbols)
// in the string
s.Length  // Length is not a method !

// Escape sequences are processed,
// prefixing with @ disables
string s = "\tThere is no" + " spoon\n";
string path = @"C:\new_directory";

// Conversion from / to a string

// decimal separator is taken from locale,
// see "cultureinfo"

float f = 10.1f; double d;
string ds = "207.666";

string sf = f.ToString();
d = Double.Parse(ds);

// comparison, the full unicode way
bool case_i = true; // case insensitive
CultureInfo c_inf = new CultureInfo("en-US");

String.Compare(str1, str2, case_i, c_inf);

// substring search, from beginning
s.IndexOf("spoon",<start_pos>,<no_of_chars>) 
s.LastIndexOf("Spoon");  // search backwards

// check leading / trailing substring
s.StartsWith("Begin");
s.EndsWith("Begin");

// Substring: start, length
s.SubString(0, 2); 

// Clear leading, trailing
// or both whitespaces
s.TrimStart(); s.TrimEnd(); s.Trim()

// search and replace
str3 = s.Replace("spoon", "pitchfork");

// combine / concat two strings
str1 = String.Concat(str1, str3);

// split input by a space to words
string[] words = Console.ReadLine.Split(" ");

// Padding left / right
s.PadLeft (
    (Console.WindowWidth() - s.Length) / 2,
    '_' );
```

---

## 05 | Flow Control

**If/Else:**

```
if (expr) {
  // Executes if expr is true
} else {
  // Optional branch
}
```

**While Loop:**

```
while (expr) {
  // Repeats until expr is false
  break;  // stops execution
}
```

**Do/While Loop:**

```
do {
  // Executed at least once
  break;  // stops execution
} while (expr);
```

**For Loop:**

```
for (int i = 0; i<100; i++) {
    // i is scoped to this loop

    // skip the iteration when i==1
    if (i==1) {
        continue;
    }
}
```

---

## 06 | Classes and Objects


```
// refer objects w/o 'System...' prefix
using System; 

namespace ns {

  class MyClass {

// Can be called w/o an instance
// as MyClass.Main(foo) due to static
// pre-C# 9 entry point of a console app

    static void Main(string[] args) {
    }

// two overloads of the sort method
// arr is passed by reference, see: out,in

    void sort(ref int[] arr, string s) {
    }

    void sort(ref byte[] arr) {
    }
  } // end class

  class c2 {

    // Constructor - optional, can be
    // also overloaded, no return value,
   // not even 'void'
    public c2(int p1) {
      this.i = new int[p1];
    }

    // default visibility is 'private',
    // still, accessible by the class'
    // own methods
    int[] i;
    private int only_mine = 42;
    private int birth_year = 1960;
    public bool to_be_or_not_to_be = true;

    // One can set get-ters and set-ters
    // for private properties; "value" is a
    // hidden parameter to the set method
    public int OnlyMine {
      get { return only_mine; }
      set { only_mine = value; }
    }

    // a standalone, r/o property
    // returning a calculated value
    public int Age {
      get { return 2021 - birth_year; }
    }

    // for simple cases, one can use lambda
    public int Age {
      get => 2021 - birth_year; 
    }

        
    // An automatic property is a private
    // propery and a public attribute.
    // No code allowed in get/set, but can
    // be prefixed with the private / public
    // modifiers. Omitting a setter means
    // its value only can be set in the c'tor
    public string Name {
      public get;
      private set
    }
      
  }  // end c2 class
}  // end namespace
```


---

## 07 | Console Handling

```
Console.Clear();  // clears the console
Console.Title = "I <heart> C#"; // set title 

// Text output
System.Console.Write(
  "Size: {0} rows, and {1} columns", n, m);

System.Console.Write(
  $"There are {n} rows, and {m} columns");

// Max. size of console window,
// value depends on the screen size
int max_cw = Console.LargestWindowWidth;
int max_ch = Console.LargestWindowHeight;

// Actual width of the console
int cw = Console.WindowWidth;             
int ch = Console.WindowHeight;

// These are writable, to resize the window
Console.WindowWidth  = 80;
Console.WindowHeight = 25;

// Colors

Console.BackgroundColor =
    ConsoleColor.DarkRed;     
Console.ForegroundColor =
    ConsoleColor.White;
// To actually do the paint with new bg color
Console.Clear();

// Back to system defaults 
Console.ResetColor();

// Cursor position, top-left is 0,0
Console.SetCursorPosition(40, 12); 

// Beep, unsupported on linux platform
Console.Beep(freq_in_hz, duration_in_ms);
```



