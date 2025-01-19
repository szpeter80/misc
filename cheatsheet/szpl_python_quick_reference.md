# Python Quick Reference

---

## 01 | Housekeeping

```
 # Create a virtual environment
python -m venv project-venv

# Record package state (outside the v. env)
pip freeze > requirements.txt

# Record package state (only local packages)
pip freeze -l > requirements.txt

# Install dependencies
pip install -r requirements.txt

# Python is VERY about identation, see PEP-8
# https://www.python.org/dev/peps/pep-0008/

# In Python strings are immutable
```

---

## 02 | Simple data types

```
 # b - bin, o - octal, d - decimal, x - hex
# base can be omitted when it can inferred
i = 0xFAFA       # integer
i = int("110")   # also int, with base 10
i = int('0xfe', 16)  # int with a hex base

# Further numeric converters: float(),
# hex(), oct(), bin()

# Converting Int to String
s = str(i);

octal = 0o1073
f"{octal}" # Decimal '571'
f"{octal:x}" # Hexadecimal'23b'
f"{octal:b}" # Binary '1000111011'
```

---

## 03 | Advanced data structures

```
# Dict: list of key-value pairs
myDict = { }
myDict['foo'] = bar
```

---

## 04 | Strings

```
# Two, equal string delimiters: ',"
# multiline strings enclosed in ''' / """

# Concatenate, result is "abc"
"a" + "b" + "c"

# Repeat, result is "BABA"
"BA" * 2

# Conversion
chr(97)            # "a"
ord(a)             # 97

# Length: number of code points
len("chr(0x1F525)")  # 1

# String can be used as a char array
# negative index counts backward from end,
# -1 represents the last character
"Hello world!"[0]   # Returns 'H'
"Hello world!"[-1]  # Returns '!'

# Slicing, accessing substrings
# if start is omitted, its zero
"Hello world!"[:5]  # Returns 'Hello'

# Striding: skip characters in the slice
# Start from end, take 'd', skip 4
('abcd'*3)[::-4] # returns 'ddd'

# Reverse a string with slice / stride
'Clean code'[::-1]   # returns 'edoc naelC'

# Built-in string methods (excerpt)

# Case conversion
s.lower(); s.upper(); s.capitalize();

# Find and replace
'Clean code'.count('c')  # 1, mind the case
# Returns -1 if not found
'Clean code'.find('c')   # Returns 6

# Character classification
s.isalnum(); s.isalpha(); s.isdigit();
s.islower(); s.isupper();

# trim whitespaces or <charspec> from left
"   Hello World!".lstrip(" loeH") # "World!"

"Hi !".rstrip("! ") # returns "Hi"
" Hi !".strip("! ") # also returns "Hi"

# replace 'l' with 'W', max 2 times
# returns 'HeWWo World!'
"Hello World!".replace("l",'W',2) 

# Split a string, res will be a List of str
res = "foo|bar|baz".split('|')

# Split a string to lines, if keepends==True
# then the newline will be included
'a\nb'.splitlines(True) # gives ['a\n', 'b']

# Joining an iterable, res2 = "foo|bar|baz"
res2 = '|'.join(res)

# Encoding to / from Unicode representations

>>> "Ä".encode('utf-8')
b'\xc3\x84'

>>> b'\xc3\x84'.decode('utf8')
'Ä'
```

---

## 05 | String formatting

```
 # Formatting, general syntax:
# <template>.format(<pos_args>, <kw_args>)

# Simple variable subtitution
# Positions are internally auto-numbered
# Excess arguments are simply ignored, no err
s = "a={}, b={}".format(a,b,c)

# Positional formatting, positional fields
# does not have to appear in any order
pos = 1
res = 42
s = "the {1}. result is {0}".format(res, pos)

# Keyword formatting
s = "the result is {r}".format(r=42)

# If both positional and keyword arguments
# present, positionals must came first

# Advanced replacement. The replacement
# fields' syntax:
# {[<name>][!<conv>][:<fmt_spec>]}
# name: position index or keyword of an arg
# conv: str() (default) / repr() / ascii()
# fmt_spec: formatting options

# create left pad, using 2 numbered params
# 'depth' is param 0, '' is param 1
ident_str = '{1:>{0}} '.format(depth, '')

# print as binary, result: '1000'
"{:b}".format(8);  

# print int as char, result: 'a'
"{:c}".format(97)

# Since 3.6, there are f-strings, officially
# "Formatted String Literals". In an
# f-string, everything which is braced by {}
# is an expression (slicing, condition, etc)
# The same formatting is used as in .format()
kid = "Molly"; age = 9
f'holly.{kid}'   # Gives "holly.molly"

# 'Molly is young.'
f'{kid} is {"young" if age<999 else "old"}.'

# String formatting with built-in methods

# returns a new 80 wide string in which
# the original contents are centered and
# the empty space is padded with '*'
'Hello world'.center(80, '*')

# left/right justify
'Hello world'.ljust(80, '*')
'Hello world'.rjust(80, '*')
```

---

## 06 | The Bytes object

```
 # a core built-in type to handle binary data
# "Próba".encode('utf-8') returns a Byte obj.

# Definition, anything greater than
# ascii 127 must be escape sequenced
my_byte= b''' "double" and 'single' quotes'''
my_byte2 = b'a\xfab' # my_byte2[1]=250 (0xfa)

# "r" prefix disables escape sequence proc.
my_byte3 = rb'a\xfab'
# you can define with bytes() too
my_byte4 = bytes('dummy', 'UTF-8')
# a byte object of 10 size, filled with nulls
my_byte5 = bytes(10)

# Bytes support the 'in' operator, slicing,
# and some methods similar to String's
```

---

## 07 | Flow control

```
# Condition
if spoon is None:
    print("There is no spoon")

# The 'in' operator returns true if the 1st
# operand is contained withing the 2nd
print('x' in "X-files")  # False due to case 

# iterate over items
for item in allCollection:
    print("item={0}".format(item))



# Exception handling
try:
   <code>
except myFamiliarError:
    <code>
```

---

## 08 | Classes and objects

```
# free object resource
del myObject
```

---

## 08 | Classes and objects

```
# read console input
code = str(input())

# multi line output
print('First line. And here comes the'\
    'second one.\n')

# use formatting, omit line break, flush buf
print("done, {0} items".format(items),
    end='', 
    flush=True)
```