using JuMP, HiGHS

solver = Model(HiGHS.Optimizer)
rows = 9
columns = 14

J = [ 1 1 1 1 0 1 0 1 1 1 1 1 1 0
      1 1 0 1 0 1 1 1 1 1 1 1 0 0
      1 1 0 1 0 1 0 1 0 1 0 0 0 1
      0 1 1 1 0 1 1 1 0 1 0 0 0 1 
      0 0 1 1 0 1 1 1 1 1 1 1 1 1 
      0 1 1 0 0 1 1 1 1 1 1 0 1 1 
      0 0 1 0 0 1 0 1 1 0 0 1 1 1 
      0 0 1 0 0 1 0 1 1 0 1 1 1 1
      1 1 1 1 0 1 1 0 1 1 1 1 1 0 ]

D = [ 0 0 0 0 0 0 0 0 1 1 0 0 0 
      0 1 0 1 1 1 1 1 1 1 1 0 0 
      0 1 1 1 0 1 1 0 1 0 1 1 1 
      1 1 1 1 1 1 1 0 1 1 1 1 1 
      1 1 1 1 1 1 1 1 0 1 1 0 1 
      0 1 1 1 0 1 1 0 1 1 1 0 1 
      1 0 1 1 1 1 1 1 1 1 0 0 1 
      1 0 1 1 1 1 0 1 0 1 1 0 1 
      1 1 1 1 0 0 1 1 0 1 1 1 0 ]

T = [ 0 1 1 1 1 1 1 1 0 0 1 0 0 0 
      0 1 0 1 1 0 1 1 0 1 1 1 0 1 
      0 0 1 1 1 0 0 1 1 1 0 1 0 1 
      0 0 1 0 1 1 1 0 1 0 1 0 1 1 
      0 1 1 1 1 0 1 0 1 1 1 1 1 1 
      0 1 0 0 0 1 1 1 1 1 0 0 1 0 
      1 1 1 1 1 0 1 0 1 1 0 1 1 0 
      1 0 1 0 1 1 0 0 1 1 1 0 1 1 
      0 1 1 1 1 0 1 1 1 1 0 1 1 1
      ]

G = [ 0 1 1 1 1 1 0 1 1 1 1 1 1 1
      0 1 1 0 1 1 1 1 1 0 1 1 1 1 
      0 1 1 1 1 1 1 0 1 0 1 1 0 1 
      1 0 1 1 1 1 1 1 1 0 1 1 1 0 
      1 1 0 1 1 0 1 0 1 0 0 1 1 1 
      0 0 1 1 1 0 1 1 1 1 1 1 1 1 
      0 1 1 1 0 0 1 0 0 0 1 1 1 0 
      0 1 1 1 1 1 1 1 1 1 0 1 1 1 
      0 1 0 1 1 1 1 1 0 1 1 1 1 1 
      ]

@variable(solver, cross[1:rows, 1:columns], Bin)

@variable(solver, square[1:rows, 1:columns], Bin)

function cross_range(x,y)
    result = []
    for i in x:-1:1
        if G[i,y] >= 1
            push!(result, (i,y))
        else
            break
        end
    end
    for i in (x+1):9
        if G[i,y] >= 1
            push!(result, (i,y))
        else
            break
        end
    end
    for i in (y-1):-1:1
        if G[x,i] >= 1
            push!(result, (x,i))
        else
            break
        end
    end
    for i in (y+1):columns
        if G[x,i] >= 1
            push!(result, (x,i))
        else
            break
        end
    end
    return result
end

function square_range(x,y)
    startx = max(1,x-1)
    endx = min(rows, x+1)
    starty = max(1,y-1)
    endy = min(columns, y+1)
    result = []
    for i in startx:endx
        for j in starty:endy
            if G[i,j] == 1
                push!(result, (i,j))
            end
        end
    end
    return result
end

@constraint(solver, [i = 1:rows, j = 1:columns; G[i, j] == 0], cross[i, j] == 0)

@constraint(solver, [i = 1:rows, j = 1:columns; G[i, j] == 0], square[i, j] == 0)

full = count(z -> z == 1, G)



con = @constraint(solver, [i = 1:rows, j = 1:columns; G[i, j] == 1], sum(square[u,w] for (u,w) in square_range(i,j)) + sum(cross[u,w] for (u,w) in cross_range(i,j)) >= 1)


@objective(solver, Min, sum(square) + sum(cross))

optimize!(solver)

objective_value(solver)

# println("Kwadraty")
# display(value.(square))

# println("Krzyże")
# display(value.(cross))


println()
println()
println()

function print_result()
    for i in 1:rows
        for j in 1:columns
            val =  + 
            if value(cross[i,j]) == 1
                print("+")
            elseif value(square[i,j]) == 1
                print("#")
            elseif G[i,j] == 1
                print("O")
            else
                print(" ")
            end
            print(" ")
        end
        print("\n")
    end
end

print_result()

# println(con)

