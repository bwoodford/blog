+++
title = '"Private" Methods in Python'
date = 2024-03-27T21:04:06-05:00
draft = false
description = 'Taking a look at the illusion behind "private" methods in Python.'
tags = ["Python"]
+++

Hola, I've been using Python to create endpoints for an experience API on a current client project. I ran into a design issue where I needed to wrap the behavior of an existing method to control its dependent parameter state. After having some internal discussions, I decided to implement a private and public version of the method. I thought this would be an easy task...

Unfortunately, I encountered an issue during unit testing. I needed to mock the private method that was being called from the public method...yikes. After a little bit of hacking (and Googling), I was able to find a way to make it work, but it required a weird syntax — syntax that I hadn't seen before.

Being the Python expert that I am, I turned to Google to see how private methods are implemented. The first result was a [GeeksForGeeks post](https://www.geeksforgeeks.org/private-methods-in-python/) which describes the implementation as 'to define a private method prefix the member name with **double underscore "__"**.' "Hmmm, seems easy enough," I thought, so I added it to my code:

```python
class PrivateFunctionExample:

    def public_function(self):
        return f"String from public function. {self.__private_function()}"

    def __private_function(self):
        return "String from private function."

def main():
    mock = PrivateFunctionExample()
    value = mock.public_function()

    # This method call results in an: 
    # "AttributeError: PrivateFunctionExample object has no attribute '__private_function'"
    # mock.__private_function()

    print(value)

if __name__ == '__main__':
    main()
```

```bash
❯ python main.py
"String from public function. String from private function."
```

And what do you know, adding the double underscore worked! I wasn't able to access the method outside of the class and the method was useable through calling `self.__private_function()`, which is exactly what I was looking for. Mission accomplished 🫡.

Well, the story didn't end there, I still needed to unit test this bad boy. From my experience with C#, I figured it would be impossible to mock this private method. However, the public method relied on calling the private method, so I needed to find a solution. 

After more carefuly crafted research (Google), I came across a [Github gist](https://gist.github.com/santiagobasulto/3056999) showing an example of patching a private method using the mock library:

```python
class Car:
    def __private(self):
        return 1

    def no_private(self):
        return self.__private()

def test_mock_private(self):
    c = Car()
    with mock.patch.object(c, '_Car__private', return_value=3) as method:
        c.no_private()
        method.assert_called_once_with()
```

The test above is able to mock the private method by calling `'_Car__private'` 👀.

This was the first time I'd ever seen this syntax. Why is the supposedly *private* method able to be accessed by calling `_CLASSNAME__private_method`? My initial gut reaction was that the method isn't actually private, and as it turns out that's very true 🤔.

I cracked open my Second Edition of Fluent Python by Luciano Ramalho to see if I could find any sections that would give me more information about this calling convention. Scanning through the Table of Contents, I found a subsection in Chapter 11 titled 'Private and "Protected" Attributes in Python'.

The first paragraph was very enlightening: "In Python, there is no way to create private variables like there is with the private modifier in Java. What we have in Python is a simple mechanism to prevent accidental overwriting of a 'private' attribute in a subclass."[^1]

I went on to read that the use of the double underscore prefix in class attribute names exists to prevent collisions between subclasses. For example, if you wrote a `Shape` object that uses a `color` instance attribute internally, and you created a subclass called `Circle` which has its own `color` instance attribute, you will clobber the original reference to `color` that's used in the inherited methods from `Shape`.

Python has a mechanism to fix this issue which is referred to as *name mangling*. If you prefix two underscores on any class attribute, the name is stored with a leading underscore and the class name. So in the case of the `Shape` and `Circle` objects, if you change the `color` attribute to `__color` the new accessors will be `_Shape__color` and `_Circle__color`.

This means you can access mangled names on any object reference. Someone could even do a nasty thing like this:

```python
class PrivateFunctionExample:

    def public_function(self):
        return f"String from public function. {self.__private_function()}"

    def __private_function(self):
        return "String from private function."

def main():
    mock = PrivateFunctionExample()

    # This isn't private at all!
    mock._PrivateFunctionExample__private_function = lambda : "String from lambda."
    value = mock.public_function()

    print(value)

if __name__ == '__main__':
    main()
```

```bash
❯ python main.py
"String from public function. String from lambda."
```

So the double underscore is exploiting name mangling! And if you go back and view the GeeksForGeeks article above, you'll notice that they describe this further down the page.

After figuring this out, I wondered..."why is this the recommended approach for private methods in Python?"

[Stackoverflow had some good discussion](https://stackoverflow.com/a/70736) on the topic. It boils down to the Python philosophy, "we're all consenting adults here".

When a Python developer adds a prefixed double underscore to a method name, the developer is implying: *this method should not be used outside of the class!* The use of name mangling also restricts a naive developer from accessing the class without knowing the convention. If a developer really wants access, they're able to take control of the mangled method and do what they please. Obviously, a developer capable of this should already understand the convention and the implications of abusing it.

In the end, I finished my unit test and kept the conventially private method in place. Even though its not really "private" in the traditional sense, I felt that my use case benefited from it. And hey, [PEP 8](https://peps.python.org/pep-0008/#method-names-and-instance-variables) recommends it.

To wrap up, looking into Python's private methods led to some eye-opening discoveries. Initially, I anticipated a straightforward implementation, but soon I fell down the rabbit hole of name mangling and the lack of traditional access modifiers.

If there's one thing I want you to take away from this article, it's this: **Python doesn't have private methods!** 😎

[^1]: Ramalho, Luciano. “11/Private and ‘Protected’ Attributes in Python.” Fluent Python, O’Reilly Media, Sebastopol, CA, 2022, pp. 384–385.
