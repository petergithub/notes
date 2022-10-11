# Effective Java (3rd edition) Notes

## 2 Creating and Destroying Objects

### Item 1: Consider static factory methods instead of constructors

### Item 2: Consider a builder when faced with many constructor parameters

### Item 3: Enforce the singleton property with a private constructor or an enumtype

### Item 4: Enforce noninstantiability with a private constructor

### Item 5: Prefer dependency injection to hardwiring resources

依赖注入需要的底层资源

### Item 6: Avoid creating unnecessary objects

#### String 例子

#### 正则匹配 例子

不直接使用 `String.matchs` 内部实现是 `Pattern.compile(regex)`, 建议直接使用 `Pattern` , 只编译一次以节约资源

#### 避免混用 autoboxing

### Item7: Eliminate obsolete object references

#### 内存泄漏 例子

#### 尽量不要自己管理内存

#### 缓存

#### 监听器和回调

### Item 8: Avoid finalizers and cleaners

finalizer 行为不可预测, 一般是不必要的

### Item 9: Prefer try-with-resources to try-finally

关闭资源优先使用 try-with-resources

```java
// try-finally is ugly when used with more than one resource!
   static void copy(String src, String dst) throws IOException {
       InputStream in = new FileInputStream(src);
       try {
           OutputStream out = new FileOutputStream(dst);
           try {
               byte[] buf = new byte[BUFFER_SIZE];
               int n;
               while ((n = in.read(buf)) >= 0)
                   out.write(buf, 0, n);
           } finally {
               out.close();
           }
       } finally {
           in.close();
} }

// try-with-resources - the the best way to close resources!
static String firstLineOfFile(String path) throws IOException {
    try (BufferedReader br = new BufferedReader(
            new FileReader(path))) {
        return br.readLine();
    }
}

// try-with-resources on multiple resources - short and sweet
static void copy(String src, String dst) throws IOException {
    try (InputStream   in = new FileInputStream(src);
        OutputStream out = new FileOutputStream(dst)) {
        byte[] buf = new byte[BUFFER_SIZE];
        int n;
        while ((n = in.read(buf)) >= 0)
            out.write(buf, 0, n);
    }
}

```

## 3 Methods Common to All Objects

### Item 10: Obey the general contract when overriding equals

1. Reflexivity
2. Symmetry
3. Transitivity
4. Consistency

### Item 11: Always override hashCode when you override equals

### Item 12: Always override toString

### Item13: Override clone judiciously

### Item 14: Consider implementing Comparable

## 4 Classes and Interfaces

### Item 15: Minimize the accessibility of classes and members

### Item 16: In public classes, use accessor methods, not public fields

### Item 24: Favor static member classes over nonstatic

嵌套类有四种: 静态成员类(static member class)、非静态成员类( nonstatic member class)、匿名类( anonymous class)和局部类( local class)。 除了第一种之外，其他三种都称为内部类( inner class)。

如果一个**嵌套类**需要在单个方法之外仍然是可见的，或者它太长了，不适合放在方法内部，就应该使用**成员类**。
如果成员类的每个实例都需要一个指向其外围实例的引用，就要把成员类做成非静态的(**非静态成员类**); 否则, 就做成静态的(**静态成员类**)。
假设这个嵌套类属于一个方法的内部，如果你只需要在一个地方创建实例， 并且已经有了一个预置的类型可以说明这个类的特征，就要把它做成匿名类 ; 否则，就做成**局部类**。

## 5 Generics

### Item 26: Don’t use raw types

无限制的通配符类型( unbounded wildcard type)

### Item 27: Eliminate unchecked warnings

要尽可能地消除每一个非受检警告
应该始终在尽可能小的范围内使用 SuppressWarnings 注解。

### Item 28: Prefer lists to arrays

数组是协变的( covariant), 表示如果 Sub 为 Super 的子类型，那么数组类型 Sub 门就是 Super []的子类型.  相反，泛型则是可变的( invariant):对于任意两个不同的类型 Typel 和 Type2, `List<Typel>` 既不是 `List<Type2>` 的子类型，也不是 `List<Type2>`的超类型[ JLS, 4.10; Naftalin07, 2.5 J

### Item 29: Favor generic types

### Item 30: Favor generic methods

有限制的通配符类型( bounded wildcard type)

### Item 31: Use bounded wildcards to increase API flexibility

为了获得最大限度的灵活性，要在表示生产者或者消费者的输入参数上 使用通配符类型.
`PECS` 表示 producer-extends, consumer-super。换句话说，如果参数化类型表示一个生产者 T，就使用`<? extends T>`;如果它表示一个消费者 T，就使用 `<? super T>`,  所有的 comparable和 comparator 都是消费者, 所以使用时始终应该是 `Comparable<? super b>` 优先于 `Comparable<T>`

### Item 32: Combine generics and varargs judiciously

## 5 Method

本章的焦点也集中在可用性, 健壮性和灵活性上

### 第49条 检查参数的有效性

发生错误之后应该尽快检测出错误

* 公有的和受保护的方法，要用 Javadoc 的@ throws 标签( tag)在文档中说明违反参数值限制时会抛出的异常
* 非公有的方法通常应该使用断言( assertion)来检查它们的参数
* 构造器参数的有效性

例外:

* 在某些情况下, 有效性检查工作非常昂贵, 或者根本是不切实际的, 而且有效性检查已隐含在计算过程中完成
* 由于无效的参数值而导致计算过程抛出的异常, 应该使用第 73 条中讲述的异常转换(exception translation)技术,  将计算过程中抛 出的异常转换为正确的异常
* 不是对参数的任何限制都是件好事, 设计方法时，应该使它们尽可能通用, 并符合实际的需要

建议:
编写方法或者构造器的时候，应该考虑它的参数有哪些限制, 写到文档中，并且在这个方法的开头处, 通过显式的检查来实施这些限制

Objects.requireNonNull 方法

### 第50条 必要时进行保护性拷贝

* 必须保护性地设计程序
* Date 已经过时了，不应该在新代码中使用, 使用 Instant (或 LocalDateTime, 或者 ZonedDateTime )代替 Date, 因为 Instant (以及另一个 java.time 类)是不可变的(详见第 17 条)

如果一个类包含有从客户端得到或者返回到客户端的可变组件，这个类就必须保护性地拷贝这些组件.
如果拷贝的成本受到限制，并且类信任它的客户端不会不恰当地修改组件，就可以在文档中指明客户端的职责是不得修改受到影响的组件，以此来代替保护性拷贝

### 第51条 谨慎设计方法签名

本条是若干 API 设计技巧的总结

* 谨慎地选择方法的名称
* 不要过于追求提供便利的方法
* 避免过长的参数列表(目标是四个参数或者更少)
* 对于参数类型，要优先使用接口而不是类
* 对于 boolean 参数，要优先使用两个元素的枚举类型

有三种技巧可以缩短过长的参数列表

* 把一个方法分解成多个方法
* 创建辅助类(helperclass)，用来保存参数的分组, 这些辅助类一般为静态成员类(详见第24条)
* 从对象构建到方法调用都采用 Builder模式

### 第52条 慎用重载

要调用哪个重载方法是在编译时做出决定的, 对于重载方法的选择是静态的，而对于被覆盖的方法 的选择则是动态的

始终可以给方法起不同的名称，而不使用重载机制, 比如 ObjectOutputStream

在 Java 5 发行版本之前，所有的基本类型都根本不 同 于所有的引用类型，但是当自动装箱出现之后，就不再如此了，它会导致真正的麻烦

反例: String 类导出两个重载的静态工厂方法: valueOf(char[])和valueOf(Object) , 当这两个方法被传递了 同样的对象 引 用时，它们所做的事情完全不同

对于多个具有相同参数数目的方法来说，应该尽量避免重载方法. 当传递同样的参数时，所有重载 方法的行为必须一致

### 第53条 慎用可变参数

java.util.Arrays#asList

* 可变参数是为 printf 而设计的,  printf 和反射机制都从可变参数 中获得了极大的益处.
* 在使用可变参数之前, 要先包含所有必要的参数, 避免出错
* 要关注使用可变参数所带来的性能影响, 每次调用可变参数方法都会导 致一次数组分配和初始化.

### 第54条:返回零长度的数组或者集合，而不是null

如果返回 null, 那样会使 API更难以使用，也更容易出错， 而且没有任何性能优势

万一有证据表示分配零长度的集合损害了程序的性能，可以通过重复返回同一个不可 变的零长度集合，避免了分配的执行

### 第55条 谨慎返回optinal

无法返回任何值的方法时，有三种方法

* 要么抛出异常
* 要么返回 null (假设返回类型是一个对象引用类型)
* `Optinal<T>`类代表的是一个不可变的容器，它可以存放单个非 null 的 T 引用，或者什么内容都没有

Optional 使用注意:

* Optional 本质上 与受检异常(详见第 71 条)相 类似, 因为它们强迫 API 用户面对没有返回值的现实
* 容器类型不应该被包装在 optional 中: 包括 Set, Map, List, Strearn、数组等
* optional 不适用于一些注重性能的情况
* 尽量不要将 optional 用作返回值以外的任何其他用途, 比如类的属性, map 的value

Optional method get(), orElse(), orElseGet(), orElseThrow(), isPresent()

### 第56条 为所有公开的API元素编写文档注释

* 在每个被导出的类、接口、构造器、方法和域声明 之前增加一个文档注释
* 方法的文档注释应该简洁地描述出它和客户端之间的约定
* @param @return @throws @implSpec
