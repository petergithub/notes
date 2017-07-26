# Scala

A val is similar to a final variable in Java. Onceinitialized,
a val can never be reassigned.

If you realize you have typed something wrong, but the interpreter is still waiting for more input, you can escape by pressing enter twice.  
every void-returning method in Java is mapped to a Unit-returning method in Scala.  unit value: `()`
the first element in a Scala array named steps is steps(0). Array is 0-based, Tuple is 1-based  
Predef.println turns around and invokes Console.println, which does the real work. When you say assert, you're invoking Predef.assert.
You start and end a raw string with three double quotation marks in a row (""").

### Misc
`val msg3: String = "Hello yet again, world!"`

```

	scala> def max(x:Int,y:Int):Int={
	     | 	if(x>y)x
	     | 	else y
	     | }
```

`args.foreach(arg => println(arg))` or `args.foreach((arg: String) => println(arg))` or `args.foreach(println)`

### Array
`val greetStrings = new Array[String](3)` or `val greetStrings: Array[String] = new Array[String](3)`
`val numNames = Array("zero", "one", "two")` transformed into `val numNames2 = Array.apply("zero", "one", "two")`

`greetStrings(i)` gets transformed into `greetStrings.apply(i)  `
`for (i <- 0 to 2) print(greetStrings(i))`
`Console println 10`
`greetStrings(0) = "Hello"` will be transformed into: `greetStrings.update(0, "Hello")`

### List
`val oneTwoThree = List(1, 2, 3)`
List has a method named `:::` for list concatenation: `val oneTwoThreeFour = oneTwo ::: threeFour`

`::` is pronounced "cons." Cons prepends a new element to the beginning of an existing list and returns the resulting list:  
`val twoThree = List(2, 3)`  
`val oneTwoThree = 1 :: twoThree`  
`::` is a method of its right operand, the list, `twoThree`.

an empty list `List()` is `Nil`, one way to initialize new lists is to string together elements with the cons operator, with `Nil` as the last element.
 `val oneTwoThree = 1 :: 2 :: 3 :: Nil` will produce the same output as `List(1, 2, 3)`

Some List methods and usages: P48 in Programming in Scala, 3rd Edition

### Tuple
tuples are immutable; tuples can contain different types of elements.  These `_N` numbers are one-based,
`val pair = (99, "Luftballons")`  
`println(pair._1)`  
`println(pair._2)`  

### Set
`var jetSet = Set("Boeing", "Airbus")`  //immutable set  
`jetSet += "Lear"`  
`println(jetSet.contains("Cessna"))`  
`jetSet += "Lear"`, is essentially a shorthand for: `jetSet = jetSet + "Lear"`

`import scala.collection.mutable`  
`val movieSet = mutable.Set("Hitch", "Poltergeist")`  //mutable set,  
`movieSet += "Shrek"`  
`println(movieSet)`  
`+=` is an actual method defined on mutable sets, so `movieSet.+=("Shrek")` is the same as `movieSet += "Shrek"`  

#### HashSet
`import scala.collection.immutable.HashSet`  
`val hashSet = HashSet("Tomatoes", "Chilies")`  
`println(hashSet + "Coriander")`  

#### HashMap
```
import scala.collection.mutable
val treasureMap = mutable.Map[Int, String]()
treasureMap += (1 -> "Go to island.")
treasureMap += (2 -> "Find big X on ground.")
treasureMap += (3 -> "Dig.")
println(treasureMap(2))
```

If you prefer an immutable map, no import is necessary, as immutable is the default map. An example
is shown in Listing 3.8:
`val romanNumeral = Map(1 -> "I", 2 -> "II", 3 -> "III", 4 -> "IV", 5 -> "V")`  
`println(romanNumeral(4))`  

Scala compiler transforms a binary operation expression like `1 -> "Go to island."` into `(1).->("Go to island.")`.

### Functional style
```
def printArgs(args: Array[String]): Unit = {
  var i = 0
  while (i < args.length) {
    println(args(i))
    i += 1
  }
}

to

def printArgs(args: Array[String]): Unit = {
  for (arg <- args)
    println(arg)
}

or

def printArgs(args: Array[String]): Unit = {
  args.foreach(println)
}

```

`def formatArgs(args: Array[String]) = args.mkString("\n")`
`val res = formatArgs(Array("zero", "one", "two"))`
`assert(res == "zero\none\ntwo")` Scala's assert method checks the passed Boolean and if it is false, throws AssertionError. If the
passed Boolean is true, assert just returns quietly  

### Read lines from file
`for (line <- Source.fromFile("path/to/file").getLines())`  
  `println(line.length + " " + line)`  

`val longestLine = lines.reduceLeft((a, b) => if (a.length > b.length) a else b)`  

### Class and objects
Public is Scala's default access level.
method parameters in Scala are vals, not vars

`// In file ChecksumAccumulator.scala
class ChecksumAccumulator {
  private var sum = 0
  def add(b: Byte): Unit = { sum += b }
  def checksum(): Int = ~(sum & 0xFF) + 1
}`

#### Singleton objects
When a singleton object shares the same name with a class, it is called that class's companion object. You must define both the class and its companion object in the same source file  

### Chapter 4 Scala application
```
object Summer {
  def main(args: Array[String]) = {
    for (arg <- args)
    println(arg + ": " + calculate(arg))
  }
}
```
`$ scalac ChecksumAccumulator.scala Summer.scala` //basic Scala compiler  
`$ fsc ChecksumAccumulator.scala Summer.scala` //for fast Scala compiler  

Scala provides a trait, `scala.App`, that can save you some finger typing. `extends App` after the name of your singleton object. Then instead of writing a main method, you place the code you would have put in the main method directly between the curly braces of the singleton object.

### Chapter 5 Basic Types and Operation
string interpolation:  
`val name = "reader"`  
`println(s"Hello, $name!")`  
`s"Hello, $name!"` yields `"Hello, reader!"`, the same result as `"Hello, " + name + "!"`.

You can place any expression after a dollar sign (`$`) in a processed string literal.
If the expression includes non-identifier characters, you must place it in curly braces, with the open curly brace immediately following the dollar sign.  
`scala> s"The answer is ${6 * 7}."`  
`res0: String = The answer is 42.`

Scala provides two other string interpolators by default: `raw` and `f`.   
The raw string interpolator behaves like s, except it does not recognize character literal escape sequences  
`println(raw"No\\\\escape!")` // prints: No\\\\escape!   

The `f` string interpolator allows you to attach printf-style formatting instructions to embedded expressions.

Operator notation is not limited to methods like `+` that look like operators in other languages. **You can use any method in operator notation.** For example, class String has a method, indexOf, that takes one Char parameter.  
`scala> "Hello, world!" indexOf "o"` // Scala invokes "Hello, world!".indexOf('o')  
`res0: Int = 4`

`scala> s indexOf ('o', 5)` // Scala invokes s.indexOf('o', 5)

`infix` operator notation take two operands, one to the left and the other to the right
`prefix` and `postfix` operators are unary: they take just one operand
In `prefix` notation, the operand is to the right of the operator. Some examples of prefix operators are `-2.0`, `!found`,

### Chapter 6 Functional Objects
In Scala, every auxiliary constructor must invoke another constructor of the same class as its first action. In other words, the first statement in every auxiliary constructor in every Scala class will have the form "this(...)".  

```
class Rational(n: Int, d: Int) {
  require(d != 0)  //precondition

	private val g = gcd(n.abs, d.abs)
	val numer = n / g
	val denom = d / g

	def this(n: Int) = this(n, 1) // auxiliary constructor

	def + (that: Rational): Rational =
		new Rational(
			numer * that.denom + that.numer * denom,
			denom * that.denom
		)

	def * (that: Rational): Rational =
		new Rational(numer * that.numer, denom * that.denom)

	override def toString = numer + "/" + denom // override toString

	private def gcd(a: Int, b: Int): Int =
		if (b == 0) a else gcd(b, a % b)
}
```

IMPLICIT CONVERSIONS, This defines a conversion method from Int to Rational    
`scala> implicit def intToRational(x: Int) = new Rational(x)`

### Chapter 7 Built-in Control Structures
#### 7.1 IF EXPRESSIONS
`val filename = if (!args.isEmpty) args(0) else "default.txt"`  

#### 7.2 WHILE LOOPS  

```
	def gcdLoop(x: Long, y: Long): Long = {
		var a = x
		var b = y
		while (a != 0) {
			val temp = a
			a = b % a
			b = temp
		}
		b
	}
```
Listing 7.2 - Calculating greatest common divisor with a `while loop`  

```
	var line = ""
	do {
		line = readLine()
		println("Read: " + line)
	} while (line != "")
```
Listing 7.3 - Reading from the standard input with `do-while`.  

Whereas in Java, assignment results in the value assigned (in this case a line from the standard input), in Scala assignment always results in the unit value, `()`  
```
var line = ""
while ((line = readLine()) != "") // This doesn't work!
	println("Read: " + line)
```

#### 7.3 FOR EXPRESSIONS
```
val filesHere = (new java.io.File(".")).listFiles
for (file <- filesHere)
	println(file)
```
Listing 7.5 - Listing files in a directory with a for expression  

With the `file <- filesHere` syntax, which is called a *generator*.

`scala> for (i <- 1 to 4) println("Iteration " + i)`	// 1,2,3,4
`scala> for (i <- 1 until 4) println("Iteration " + i)`	// 1,2,3

##### Filtering
```
val filesHere = (new java.io.File(".")).listFiles
for (file <- filesHere if file.getName.endsWith(".scala"))
	println(file)
```
Listing 7.6 - Finding .scala files using a for with a filter.  
```
for (
	file <- filesHere
	if file.isFile
	if file.getName.endsWith(".scala")
) println(file)
```
Listing 7.7 - Using multiple filters in a for expression.  

##### Nested iteration
The outer loop iterates through filesHere, and the inner loop iterates through fileLines(file) for any file that ends with .scala.  
```
def fileLines(file: java.io.File) = scala.io.Source.fromFile(file).getLines().toList
def grep(pattern: String) =
	for (
		file <- filesHere
		if file.getName.endsWith(".scala");
		line <- fileLines(file)
		if line.trim.matches(pattern)
	) println(file + ": " + line.trim)

grep(".*gcd.*")
```
Listing 7.8 - Using multiple generators in a for expression  

##### Producing a new collection
`for clauses yield body`  
the result is an Array[File], becausefilesHere is an array and the type of the yielded expression is File  
```
def scalaFiles =
	for {
		file <- filesHere
		if file.getName.endsWith(".scala")
	} yield file
```

#### 7.4 EXCEPTION HANDLING WITH TRY EXPRESSIONS
Catching exceptions
```
import java.io.FileReader
import java.io.FileNotFoundException
import java.io.IOException

try {
	val f = new FileReader("input.txt")
	// Use and close file
} catch {
	case ex: FileNotFoundException => // Handle missing file
	case ex: IOException => // Handle other I/O error
}
```
Listing 7.11 - A try-catch clause in Scala.

#### 7.5 MATCH EXPRESSIONS
```
val firstArg = if (!args.isEmpty) args(0) else ""

val friend =
	firstArg match {
		case "salt" => "pepper"
		case "chips" => "salsa"
		case "eggs" => "bacon"
		case _ => "huh?"
	}
println(friend)
```

#### 7.6 LIVING WITHOUT BREAK AND CONTINUE
```
import scala.util.control.Breaks._
import java.io._

val in = new BufferedReader(new InputStreamReader(System.in))

breakable {
	while (true) {
		println("? ")
		if (in.readLine() == "") break
	}
}
```

### Chapter 10 Composition and Inheritance
```
class ArrayElement(conts: Array[String]) extends Element {
      def contents: Array[String] = conts
    }
```

Java's four namespaces are fields, methods, types, and packages. By contrast, Scala's two namespaces are:  
* values (fields, methods, packages, and singleton objects)
* types (class and trait names)

Invoking superclass constructors: `class LineElement(s: String) extends ArrayElement(Array(s)) {}`

```
	object Element {

	      def elem(contents: Array[String]): Element = 
	        new ArrayElement(contents)

	      def elem(chr: Char, width: Int, height: Int): Element = 
	        new UniformElement(chr, width, height)

	      def elem(line: String): Element = 
	        new LineElement(line)
	    }
```		
Listing 10.10 - A factory object with factory methods.

### Chapter 11 Scala's Hierarchy
In Scala, every class inherits from a common superclass named `Any`. `Null` and `Nothing`, which essentially act as common subclasses.  
The root class Any has two subclasses: `AnyVal` and `AnyRef`. `AnyVal` is the parent class of value classes in Scala. The other subclass of the root class `Any` is class `AnyRef`. This is the base class of all reference classes in Scala. As mentioned previously, on the Java platform `AnyRef` is in fact just an alias for class `java.lang.Object`. So classes written in Java, as well as classes written in Scala, all inherit from `AnyRef`

class `AnyRef` defines an additional `eq` method, which cannot be overridden and is implemented as reference equality (i.e., it behaves like `==` in Java for reference types). There's also the negation of `eq`, which is called `ne`.  

### Chapter 12 Traits

```
trait Philosophical {
  def philosophize() = {
    println("I consume memory, therefore I am!")
  }
}

class Frog extends Animal with Philosophical with HasLegs {
      override def toString = "green"
}
```
