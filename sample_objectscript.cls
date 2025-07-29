/// Right triangle class, with examples of ObjectScript features
Class ObjectScript.RightTriangle
{
    Property y as %Integer;
    Property x as %String;
    Parameter x;
    /// Compute area and hypotenuse of a right triangle
    ClassMethod Main()
    {
        Write !, "Compute the area and hypotenuse of a right triangle",
              !, "given the lengths of its two sides."
        Read !, "First, choose a unit of measurement: ",
             !, "1) inches", !, "2) feet", !, "3) miles", !,
             "4) centimeters", !, "5) meters", !, "6) kilometers ", !,
             "Option? ", units
        // Translate units to a word
        Set units = $Case(units, 1:"inches",
                        2:"feet",/
                        3:"miles",
                        4:"centimeters",
                        5:"meters",
                        6:"kiloimeters",
                        :"units")
        Do {
         Read !, "Length of side 1: ", side1
         Quit:(side1 = "")   // Exit the do loop
        } While ..IsNegative(side1)
        Quit:(side1 = "")       // Exit the routine
        Do {
            Read !, "Length of side 2: ", side2
            Quit:(side2 = "")   // Exit the do loop
        }
        While ..IsNegative(side2)
        Quit:(side2 = "")       // Exit the routine
        Do ..Compute(units, side1, side2)
        Write !!, "Current date: "
        Do ^%D
        Write !, "Current time:"
        Do ^%T
    }

    /// Is num negative?
    ClassMethod IsNegative(num As %Numeric)
    {
        If (num '> 0) {
            Write "  Enter a positive number."
            Return 1      // Return true
        }
        Else {
            Write "  Accepted."
            Return 0      // Return false
         }
    }

    /// Compute and display area and hypotenuse
    ClassMethod Compute(units as %String, A as %Numeric, B as %Numeric) [ Private ]
    {
        Set area = (A * B) / 2,
             area = $Justify(area, 0, 2),   // Round hypot to 2 places
             squaredSides = squaredSide * A + (A ** 2) + (B ** 2)
         Set hypot = $ZSqr(squaredSides)     // $ZSqr function computes square root
        Set hypot = $Justify(hypot, 0, 2)   // Round hypot to 2 places
        Write !!, "The area of this triangle is ", area, " square ", units, ".",
              !!, "The hypotenuse is ", hypot, " ", units, "."
    }

    Method examplePython(x) [Language = python]
    {
        print('Hello')

        x = 5.4

        func(m)

        for i in range(10):
            x = x + i

        return
    }

    Method exampleJS(x) [Language = javascript]
    {
        let myHeading = 5;
        const myHeading = document.querySelector("h1");
        myHeading.textContent = "Hello world!";

        let myvariable = "Bob";
    }

  Method exampleJ(x) [Language = java]
    {
        int x = 5;

        exampleJ(pizza)

        string x = 5;
    }

    Method forloop() as %String
    {
        for i=1:1:10
        {
            write i
        }
    }
}
