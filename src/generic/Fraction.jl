###############################################################################
#
#   Fraction.jl : generic fraction fields
#
###############################################################################

export FractionField, Fraction, num, den

###############################################################################
#
#   Data type and parent object methods
#
###############################################################################

elem_type{T <: RingElem}(::FractionField{T}) = Fraction{T}

base_ring(a::FractionField) = a.base_ring

base_ring(a::FractionElem) = base_ring(parent(a))

parent(a::FractionElem) = a.parent

function check_parent(a::FractionElem, b::FractionElem)
   parent(a) != parent(b) && error("Incompatible rings in fraction field operation")
end

###############################################################################
#
#   Constructors
#
###############################################################################

function //{T <: RingElem}(x::T, y::T)
   y == 0 && throw(DivideError())
   g = gcd(x, y)
   z = Fraction{T}(divexact(x, g), divexact(y, g))
   try
      z.parent = FractionDict[R]
   catch
      z.parent = FractionField(parent(x))
   end
   return z
end

//{T <: RingElem}(x::T, y::Integer) = x//parent(x)(y)

//{T <: RingElem}(x::Integer, y::T) = parent(y)(x)//y

# disambiguation
//{T <: RingElem}(x::Fraction{T}, y::Fraction{T}) = divexact(x, y)

//{T <: RingElem}(x::T, y::Fraction{T}) = parent(y)(x)//y

//{T <: RingElem}(x::Fraction{T}, y::T) = x//parent(x)(y)

###############################################################################
#
#   Basic manipulation
#
###############################################################################

function hash(a::FractionElem)
   h = 0x8a30b0d963237dd5
   return h $ hash(num(a)) $ hash(den(a))
end

function num(a::Fraction)
   u = canonical_unit(a.den)
   return divexact(a.num, u)
end

function den(a::Fraction)
   u = canonical_unit(a.den)
   return divexact(a.den, u)
end

zero(a::FractionField) = parent(a)(0)

one(a::FractionField) = parent(a)(1)

iszero(a::FractionElem) = iszero(num(a))

isone(a::FractionElem) = num(a) == den(a)

isunit(a::FractionElem) = num(a) != 0

function deepcopy{T <: RingElem}(a::Fraction{T})
   v = Fraction{T}(deepcopy(num(a)), deepcopy(den(a)))
   v.parent = parent(a)
   return v
end 

###############################################################################
#
#   Canonicalisation
#
###############################################################################

canonical_unit(a::FractionElem) = a

###############################################################################
#
#   String I/O
#
###############################################################################

function show(io::IO, x::FractionElem)
   u = canonical_unit(den(x))
   n = divexact(num(x), u)
   d = divexact(den(x), u);
   if d != 1 && needs_parentheses(n)
      print(io, "(")
   end
   print(io, n)
   if den != 1
      if needs_parentheses(n)
         print(io, ")")
      end
      print(io, "//")
      if needs_parentheses(d)
         print(io, "(")
      end
      print(io, d)
      if needs_parentheses(d)
         print(io, ")")
      end
   end
end

function show(io::IO, a::FractionField)
   print(io, "Fraction field of ", base_ring(a))
end

needs_parentheses(x::FractionElem) = den(x) == 1 && needs_parentheses(num(x))

is_negative(x::FractionElem) = !needs_parentheses(num(x)) && is_negative(num(x))

show_minus_one{T <: RingElem}(::Type{FractionElem{T}}) = show_minus_one(T)

###############################################################################
#
#   Unary operators
#
###############################################################################

function -{T <: RingElem}(a::Fraction{T})
   z = Fraction{T}(-num(a), den(a))
   z.parent = parent(a)
   return z
end

###############################################################################
#
#   Binary operators
#
###############################################################################

function +{T <: RingElem}(a::Fraction{T}, b::Fraction{T})
   check_parent(a, b)
   n = num(a)*den(b) + num(b)*den(a)
   d = den(a)*den(b)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

function -{T <: RingElem}(a::Fraction{T}, b::Fraction{T})
   check_parent(a, b)
   n = num(a)*den(b) - num(b)*den(a)
   d = den(a)*den(b)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

function *{T <: RingElem}(a::Fraction{T}, b::Fraction{T})
   check_parent(a, b)
   g1 = gcd(num(a), den(b))
   g2 = gcd(num(b), den(a))
   n = divexact(num(a), g1)*divexact(num(b), g2)
   d = divexact(den(a), g2)*divexact(den(b), g1)
   z = Fraction{T}(n, d)
   z.parent = parent(a)
   return z
end

###############################################################################
#
#   Ad hoc binary operators
#
###############################################################################

function *{T <: RingElem}(a::Fraction{T}, b::Integer)
   c = base_ring(a)(b)
   g = gcd(den(a), c)
   n = num(a)*divexact(c, g)
   d = divexact(den(a), g)
   z = Fraction{T}(n, d)
   z.parent = parent(a)
   return z
end

function *{T <: RingElem}(a::Integer, b::Fraction{T})
   c = base_ring(b)(a)
   g = gcd(den(b), c)
   n = num(b)*divexact(c, g)
   d = divexact(den(b), g)
   z = Fraction{T}(n, d)
   z.parent = parent(b)
   return z
end

function *{T <: RingElem}(a::Fraction{T}, b::T)
   g = gcd(den(a), b)
   n = num(a)*divexact(b, g)
   d = divexact(den(a), g)
   z = Fraction{T}(n, d)
   z.parent = parent(a)
   return z

end

function *{T <: RingElem}(a::T, b::Fraction{T})
   g = gcd(den(b), a)
   n = num(b)*divexact(a, g)
   d = divexact(den(b), g)
   z = Fraction{T}(n, d)
   z.parent = parent(b)
   return z
end

function +{T <: RingElem}(a::Fraction{T}, b::Integer)
   n = num(a) + den(a)*b
   d = den(a)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

function -{T <: RingElem}(a::Fraction{T}, b::Integer)
   n = num(a) - den(a)*b
   d = den(a)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

+{T <: RingElem}(a::Integer, b::Fraction{T}) = b + a

function -{T <: RingElem}(a::Integer, b::Fraction{T})
   n = a*den(b) - num(b)
   d = den(b)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(b)
   return z
end

function +{T <: RingElem}(a::Fraction{T}, b::T)
   n = num(a) + den(a)*b
   d = den(a)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

function -{T <: RingElem}(a::Fraction{T}, b::T)
   n = num(a) - den(a)*b
   d = den(a)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

+{T <: RingElem}(a::T, b::Fraction{T}) = b + a

function -{T <: RingElem}(a::T, b::Fraction{T})
   n = a*den(b) - num(b)
   d = den(b)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(b)
   return z
end

###############################################################################
#
#   Comparisons
#
###############################################################################

function =={T <: RingElem}(x::FractionElem{T}, y::FractionElem{T})
   check_parent(x, y)
   return (den(x) == den(y) && num(x) == num(y)) || (num(x)*den(y) == den(x)*num(y))
end

###############################################################################
#
#   Ad hoc comparisons
#
###############################################################################

function ==(x::FractionElem, y::Integer)
   return (den(x) == 1 && num(x) == y) || (num(x) == den(x)*y)
end

==(x::Integer, y::FractionElem) = y == x

function =={T <: RingElem}(x::FractionElem{T}, y::T)
   return (den(x) == 1 && num(x) == y) || (num(x) == den(x)*y)
end

=={T <: RingElem}(x::T, y::FractionElem{T}) = y == x


###############################################################################
#
#   Inversion
#
###############################################################################

function inv{T <: RingElem}(a::FractionElem{T})
   num(a) == 0 && throw(DivideError())
   z = Fraction{T}(den(a), num(a))
   z.parent = parent(a)
   return z
end

###############################################################################
#
#   Exact division
#
###############################################################################

function divexact{T <: RingElem}(a::FractionElem{T}, b::FractionElem{T})
   check_parent(a, b)
   g1 = gcd(num(a), num(b))
   g2 = gcd(den(b), den(a))
   n = divexact(num(a), g1)*divexact(den(b), g2)
   d = divexact(den(a), g2)*divexact(num(b), g1)
   z = Fraction{T}(n, d)
   z.parent = parent(a)
   return z
end

###############################################################################
#
#   Ad hoc exact division
#
###############################################################################

function divexact{T <: RingElem}(a::FractionElem{T}, b::Integer)
   b == 0 && throw(DivideError())
   c = base_ring(a)(b)
   g = gcd(num(a), c)
   n = divexact(num(a), g)
   d = den(a)*divexact(c, g)
   z = Fraction{T}(n, d)
   z.parent = parent(a)
   return z
end

function divexact{T <: RingElem}(a::Integer, b::FractionElem{T})
   b == 0 && throw(DivideError())
   c = base_ring(b)(a)
   g = gcd(num(b), c)
   n = den(b)*divexact(c, g)
   d = divexact(num(b), g)
   z = Fraction{T}(n, d)
   z.parent = parent(b)
   return z
end

# remove ambiguity
divexact{T <: RingElem}(a::FractionElem{T}, b::Poly{T}) = error("Not supported")

# remove ambiguity
divexact{T <: RingElem}(a::Poly{T}, b::FractionElem{T}) = error("Not supported")

function divexact{T <: RingElem}(a::FractionElem{T}, b::T)
   b == 0 && throw(DivideError())
   g = gcd(num(a), b)
   n = divexact(num(a), g)
   d = den(a)*divexact(b, g)
   z = Fraction{T}(n, d)
   z.parent = parent(a)
   return z
end

function divexact{T <: RingElem}(a::T, b::FractionElem{T})
   b == 0 && throw(DivideError())
   g = gcd(num(b), a)
   n = den(b)*divexact(a, g)
   d = divexact(num(b), g)
   z = Fraction{T}(n, d)
   z.parent = parent(b)
   return z
end

###############################################################################
#
#   Powering
#
###############################################################################

function ^{T <: RingElem}(a::FractionElem{T}, b::Int)
   if b < 0
      a = inv(a)
      b = -b
   end
   z = Fraction{T}(num(a)^b, den(a)^b)
   z.parent = parent(a)
   return z
end

###############################################################################
#
#   GCD
#
###############################################################################

function gcd{T <: RingElem}(a::FractionElem{T}, b::FractionElem{T})
   check_parent(a, b)
   n = gcd(num(a)*den(b), den(a)*num(b))
   d = den(a)*den(b)
   g = gcd(n, d)
   z = Fraction{T}(divexact(n, g), divexact(d, g))
   z.parent = parent(a)
   return z
end

###############################################################################
#
#   Unsafe operators and functions
#
###############################################################################

function mul!{T <: RingElem}(c::Fraction{T}, a::Fraction{T}, b::Fraction{T})
   g1 = gcd(num(a), den(b))
   g2 = gcd(num(b), den(a))
   c.num = divexact(num(a), g1)*divexact(num(b), g2)
   c.den = divexact(den(a), g2)*divexact(den(b), g1)
end

function addeq!{T <: RingElem}(c::Fraction{T}, a::Fraction{T})
   n = c.num*den(a) + num(a)*c.den
   d = c.den*den(a)
   g = gcd(n, d)
   c.num = divexact(n, g)
   c.den = divexact(d, g)
end

###############################################################################
#
#   Promotion rules
#
###############################################################################

Base.promote_rule{T <: RingElem}(::Type{Fraction{T}}, ::Type{T}) = Fraction{T}

Base.promote_rule{T <: RingElem, U <: Integer}(::Type{Fraction{T}}, ::Type{U}) = Fraction{T}

###############################################################################
#
#   Parent object call overloading
#
###############################################################################

function Base.call{T <: RingElem}(a::FractionField{T}, b::RingElem)
   return a(base_ring(a)(b))
end

function Base.call{T <: RingElem}(a::FractionField{T})
   z = Fraction{T}(zero(base_ring(a)), one(base_ring(a)))
   z.parent = a
   return z
end

function Base.call{T <: RingElem}(a::FractionField{T}, b::T)
   parent(b) != base_ring(a) && error("Could not coerce to fraction")
   z = Fraction{T}(b, one(base_ring(a)))
   z.parent = a
   return z
end

function Base.call{T <: RingElem}(a::FractionField{T}, b::Integer)
   z = Fraction{T}(base_ring(a)(b), one(base_ring(a)))
   z.parent = a
   return z
end

function Base.call{T <: RingElem}(a::FractionField{T}, b::Fraction{T})
   a != parent(b) && error("Could not coerce to fraction")
   return b
end

###############################################################################
#
#   FractionField constructor
#
###############################################################################

function FractionField(R::Ring)
   R2 = R
   T = elem_type(R)
   parent_type = Fraction{T}
   while base_ring(R2) != None
      R2 = base_ring(R2)
      T2 = elem_type(R2)
      eval(:(Base.promote_rule(::Type{$parent_type}, ::Type{$T2}) = $parent_type))
   end

   return FractionField{T}(R)
end

