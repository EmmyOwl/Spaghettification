using Base: Int16, Tuple
using LinearAlgebra
using Printf

function abbild(p)
    # Define plane
    planeNorm = [0,0,1]
    planePnt = [0,0,250]

    # Define ray
    origin = [0,0,0]

    nDotu = dot(planeNorm, p)
    originPlaneDistance  = origin - planePnt
    si = -dot(planeNorm, originPlaneDistance) / nDotu
    intersect = originPlaneDistance .+ si .* p .+ planePnt
    # if p is in the picture of the camera
    if (intersect[1] <= 250 && intersect[1] >= -250) && (intersect[2] <= 250 && intersect[2] >= -250)
        return (floor(Int16,intersect[1]),floor(Int16,intersect[2]))
     # if p is not in the picture of the camera
    else
        return nothing
    end
end
    
function is_visible(p,m,r)
    isInImage = abbild(p)
    numberOfIntersects = intersectSphere(p,m,r)
    # if p is in the image of the camera and the line segment intersects with the sphere at most in 1 point
    if  isInImage !== nothing && numberOfIntersects == 1
        return true
    # if p is not in the image of the camera or the line segment intersects with the sphere in a 2nd point
    else
        return false
    end
end

function intersectSphere(p,m,r)
    α = p[1]
    β = p[2]
    γ = p[3]
    x0 = m[1]
    y0 = m[2]
    z0 = m[3]
    a = α^2 + β^2 + γ^2
    b = -2*(α*x0+β*y0+γ*z0)
    c = (x0^2+y0^2+z0^2-r^2)
    t = 250/γ

    # catch exeption: if discriminant is negative
    try
        sqrt(b^2-4*a*c)
    catch exception
        if isa(exception, DomainError)
            #solutions = 0
            #println("No solutions")
        end
    end
    D = sqrt(b^2-4*a*c)

    # Case 1: one intersection point
    if D == 0
        solutions = 1
    
    # Case 2: two intersection points
    elseif D > 0
        solutions = 2
    end

    t1 = (-b+sqrt(b^2-4*a*c))/(2*a)
    t2 = (-b-sqrt(b^2-4*a*c))/(2*a)
    @printf("p(%d, %d, %d)\n", p[1], p[2], p[3])
    @printf("t1: %f\n", t1)
    @printf("p1: %d(%d), %d(%d), %d(%d)\n", t1, p[1], t1, p[2], t1, p[3])
    @printf("p1: %d, %d, %d\n", (t1*(p[1])), (t1*(p[2])), (t1*(p[3])))
    @printf("t2: %f\n", t2)
    @printf("p2: %d(%d), %d(%d), %d(%d)\n", t2, p[1], t2, p[2], t2, p[3])
    @printf("p2: %d, %d, %d\n", (t2*(p[1])), (t2*(p[2])), (t2*(p[3])))

    intersect1 = 1 >= round(t1, digits=3) > t
    intersect2 = 1 >= round(t2, digits=3) > t
    println(intersect1)
    println(intersect2)


    return solutions
end

####################################### MAIN #################################################
    p = [0,50,500]
    result = abbild(p)
    println("pDash: ", result)
    m = [0,0,500]
    r = 50
    result2 = is_visible(p,m,r)
    #println(result2)