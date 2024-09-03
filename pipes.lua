local pipes = {}  -- Canos (retângulos)
local canvas_width = love.graphics.getWidth()
local canvas_height = love.graphics.getHeight()

local function pipesInit()
    pipes.clock = 0  -- Tempo decorrido desde o último cano gerado
    pipes.gen_rate = 3  -- Tempo (em segundos) para gerar um novo cano
end

local function pipesReset()
    pipes.clock = 0
    while #pipes > 0 do
        table.remove(pipes, 1)  -- Remove todos os canos da tabela
    end
end

-- Cria canos em posições aleatórias
local function pipeCreate()
    local pipe = {}
    pipe.width = 50
    pipe.height1 = math.random(100, canvas_height - 250)  -- Altura do cano superior (cano 1)
    pipe.empty_space = 250  -- Espaço entre o cano superior e o inferior
    pipe.height2 = canvas_height - pipe.height1 - pipe.empty_space  -- Altura do cano inferior (cano 2)
    pipe.x = canvas_width  -- Posição inicial do cano (fora da tela à direita)
    pipe.speed = -100  -- Velocidade de movimento dos canos para a esquerda
    return pipe
end

-- Atualiza a posição dos canos
local function pipesUpdate(dt)
    pipes.clock = pipes.clock + dt
    if pipes.clock > pipes.gen_rate then
        pipes.clock = 0
        table.insert(pipes, pipeCreate())  -- Adiciona um novo cano
    end

    for k, pipe in ipairs(pipes) do
        pipe.x = pipe.x + pipe.speed * dt  -- Move o cano para a esquerda (transição de tela)
    end

    -- Conta quantos canos estão fora da tela
    local dead_pipes_count = 0
    for k, pipe in ipairs(pipes) do
        if pipe.x < -pipe.width then
            dead_pipes_count = dead_pipes_count + 1
        else
            break
        end
    end

    -- Remove os canos que saíram da tela
    for _ = 1, dead_pipes_count do
        table.remove(pipes, 1)
    end
end

-- Desenha os canos na tela
local function pipesDraw()
    for _, pipe in ipairs(pipes) do
        love.graphics.setColor(0, 0, 128)  -- Cor dos canos
        love.graphics.rectangle("fill", pipe.x, 0, pipe.width, pipe.height1)  -- Cano superior
        love.graphics.rectangle("fill", pipe.x, canvas_height - pipe.height2, pipe.width, pipe.height2)  -- Cano inferior
    end

    love.graphics.setColor(1, 1, 1)  -- Reseta a cor do cano pra branco (pra conseguir desenhar novos depois)
end

-- Verifica colisão do pássaro com os canos
local function checkCollision(pipe, bird)
    local bird_width = bird.sprite:getWidth() * 0.2
    local bird_height = bird.sprite:getHeight() * 0.2

    -- Verifica colisão com o cano superior
    if bird.x < pipe.x + pipe.width and
       bird.x + bird_width > pipe.x and
       bird.y < pipe.height1 then
        return true
    end

    -- Verifica colisão com o cano inferior
    if bird.x < pipe.x + pipe.width and
       bird.x + bird_width > pipe.x and
       bird.y + bird_height > canvas_height - pipe.height2 then
        return true
    end

    return false
end

-- Exporta as funções e propriedades dos canos
return {
    pipes = pipes,
    pipesInit = pipesInit,
    pipesReset = pipesReset,
    pipesUpdate = pipesUpdate,
    pipesDraw = pipesDraw,
    checkCollision = checkCollision
}
