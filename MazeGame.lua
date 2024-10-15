FieldState =
{
    EMPTY = " ",
    WALL = "#",
    PLAYER = "P",
    TARGET = "T"
}

Command =
{
    UP = "W",
    LEFT = "A",
    DOWN = "S",
    RIGHT = "D"
}

function RemoveRandomElement(data)
    local count = #data
    if count == 0 then
        return nil
    end
    local elementIndex = math.random(1, count)
    local element = data[elementIndex]
    table.remove(data, elementIndex)
    return element
end

function Shuffle(data)
    local count = #data
    for i = 1, count do
        local index = math.random(1, count)
        if index ~= i then
            local tempX = data[index][1]
            local tempY = data[index][2]
            data[index][1] = data[i][1]
            data[index][2] = data[i][2]
            data[i][1] = tempX
            data[i][2] = tempY
        end
    end
end

function IsPointInMaze(maze, x, y)
    local length = #maze
    local width = #maze[1]
    return x >= 2 and x <= width - 1 and y >= 2 and y <= length - 1
end

function RoadExists(maze, x, y)
    return IsPointInMaze(maze, x, y) and maze[y][x] ~= FieldState.WALL
end

function AddVisitedPointIfItExists(maze, points, x, y)
    if IsPointInMaze(maze, x, y) and not RoadExists(maze, x, y) then
        points[x .. "," .. y] = FieldState.EMPTY
    end
end

function AddVisitedPoints(maze, points, x, y)
    AddVisitedPointIfItExists(maze, points, x - 2, y)
    AddVisitedPointIfItExists(maze, points, x + 2, y)
    AddVisitedPointIfItExists(maze, points, x, y - 2)
    AddVisitedPointIfItExists(maze, points, x, y + 2)
end

function Connect(maze, x, y)
    local Directions = {
        {-1, 0},
        {1, 0},
        {0, -1},
        {0, 1}
    }
    Shuffle(Directions)
    for i = 1, #Directions do
        local NeighboringX = x + Directions[i][1] * 2
        local NeighboringY = y + Directions[i][2] * 2
        if RoadExists(maze, NeighboringX, NeighboringY) then
            local ConnectorX = x + Directions[i][1]
            local ConnectorY = y + Directions[i][2]
            maze[ConnectorY][ConnectorX] = FieldState.EMPTY
            return
        end
    end
end

function GenerateMaze(width, length)
    local maze = {}
    local framedWidth = width + 2
    local framedLength = length + 2
    for i = 1, framedLength do
        maze[i] = {}
        for j = 1, framedWidth do
            maze[i][j] = FieldState.WALL
        end
    end
    local x = math.random(2, math.floor(width / 2)) * 2
    local y = math.random(2, math.floor(length / 2)) * 2
    local connectPoints = {}
    connectPoints[x .. "," .. y] = FieldState.EMPTY
    while next(connectPoints) do
        local pointKey = next(connectPoints)
        local point = { x = tonumber(pointKey:match("([^,]+)")), y = tonumber(pointKey:match(",([^,]+)")) }
        connectPoints[pointKey] = nil
        maze[point.y][point.x] = FieldState.EMPTY
        Connect(maze, point.x, point.y)
        AddVisitedPoints(maze, connectPoints, point.x, point.y)
    end
    return maze
end

function PrintMaze(maze)
    for y = 1, #maze do
        for x = 1, #maze[1] do
            io.write(maze[y][x] .. " ")
        end
        print()
    end
    print()
end

function InputMovingCommand()
    local inputCommand
    local isCommandRecognized
    repeat
        print("Input " .. Command.UP .. " for moving up, " .. Command.DOWN .. " for moving down, " .. Command.LEFT .. " for moving left or " .. Command.RIGHT .. " for moving right: ")
        inputCommand = string.upper(io.read())
        isCommandRecognized = false
        for name, value in pairs(Command)
        do
            if (inputCommand == value)
            then
                isCommandRecognized = true
                break
            end
        end
        if (not isCommandRecognized)
        then
            print("Command was not recognized.")
        end
    until isCommandRecognized
    return inputCommand
end

function TryToMovePlayerWithCommandAndReturnTrueIfWin(maze, currentPlayerY, currentPlayerX, command)
    local playerOffsetY, playerOffsetX
    if command == Command.UP
    then
        playerOffsetY, playerOffsetX = -1, 0
    elseif command == Command.DOWN
    then
        playerOffsetY, playerOffsetX = 1, 0
    elseif command == Command.LEFT
    then
        playerOffsetY, playerOffsetX = 0, -1
    elseif command == Command.RIGHT
    then
        playerOffsetY, playerOffsetX = 0, 1
    end
    local potentialPlayerPositionY, potentialPlayerPositionX = currentPlayerY + playerOffsetY, currentPlayerX + playerOffsetX
    if(potentialPlayerPositionY > 0 and potentialPlayerPositionY <= #maze and potentialPlayerPositionX > 0 and potentialPlayerPositionX <= #maze[potentialPlayerPositionY])
    then
        if(maze[potentialPlayerPositionY][potentialPlayerPositionX] == FieldState.TARGET)
        then
            return true, potentialPlayerPositionY, potentialPlayerPositionX
        elseif(maze[potentialPlayerPositionY][potentialPlayerPositionX] == FieldState.EMPTY)
        then
            maze[potentialPlayerPositionY][potentialPlayerPositionX] = FieldState.PLAYER
            maze[currentPlayerY][currentPlayerX] = FieldState.EMPTY
            currentPlayerY, currentPlayerX = potentialPlayerPositionY, potentialPlayerPositionX
        end
    end
    return false, currentPlayerY, currentPlayerX
end

function InputCommandAndTryToMovePlayerAndReturnTrueIfWin(maze, currentPlayerY, currentPlayerX)
    local inputCommand = InputMovingCommand()
    return TryToMovePlayerWithCommandAndReturnTrueIfWin(maze, currentPlayerY, currentPlayerX, inputCommand)
end

function WinGame()
    print("Congratulations! You won!!!")
end

function StartGameUntilVictory(maze, currentPlayerY, currentPlayerX)
    local didPlayerWin, newPlayerY, newPlayerX = InputCommandAndTryToMovePlayerAndReturnTrueIfWin(maze, currentPlayerY, currentPlayerX)
    if didPlayerWin
    then
        WinGame()
    else
        PrintMaze(maze)
        StartGameUntilVictory(maze, newPlayerY, newPlayerX)
    end
end


math.randomseed(os.time())
local width, length = 31, 31
local maze = GenerateMaze(width, length)
width = width + 2
length = length + 2
local currentPlayerY, currentPlayerX = -1, -1
for i = length,1,-1
do
    if(maze[i][2] == FieldState.EMPTY)
    then
        currentPlayerY, currentPlayerX = i, 2
        maze[currentPlayerY][currentPlayerX] = FieldState.PLAYER
        break
    end
end
local targetY, targetX = -1, -1
for i = length,1,-1
do
    if(maze[2][i] == FieldState.EMPTY)
    then
        targetY, targetX = 2, i
        maze[targetY][targetX] = FieldState.TARGET
        break
    end
end
if (currentPlayerY == -1 or targetY == -1)
then
    print("Unable to place player and target!")
    os.exit(0)
end
print("In this game, you will be able to move the player (marked as \"P\") up (command W), down (command S), left (command A) or right (command D), but you won't be able to move through the walls.\nYour goal is to move the player to the target (marked as \"T\"). Good luck!")
PrintMaze(maze)
StartGameUntilVictory(maze, currentPlayerY, currentPlayerX)