#!/usr/bin/env ruby

require 'json'

######################## FUNÇAO PARSE JSON ########################################
def session_parser(input_str)
  return JSON.parse(input_str) # faz o parse da string lida do arquivo input
end

######################## FUNÇAO SUPORTE ############################################
def time_session_manager_2(hashes)
### recebe um array de hashes com TIMESTAMPS, 
### calcula diferença de tempo e retorna um array de hashes estruturado
  
  last = hashes.length - 1                     # guardando o limite do array (len - 1)

  startTime = 0                                # inicializaçao de variaveis uteis
  out_ary = []                                 #
  out_pages = []                               #
  session_hash = {}                            #
  current_duration = 0                         #
  

  hashes.each.with_index do |hsh, i|             # iteração por cada hash do array com index 
    startTime = hsh.values[0] if startTime == 0  # Se 0, o timestamp atual é o começo da sessao
    current_duration = hsh.values[0] - startTime # tempo atual - startime
    out_pages << hsh.keys[0]                     # adicionar urls para um array
    
    if current_duration <= 600000                # Se a duração atual nao passar os 10 min
      if i < last                                # Se não for o último ciclo
        if hashes[1+i].values[0] - startTime > 600000  # Dif entre o elemento seguinte
          session_hash = {
                  "duration": current_duration,
                  "pages": out_pages,
                  "startTime": startTime }
           out_ary << session_hash
           out_pages = []                              # limpar variaveis
           startTime = 0                               #
           next
        end
      else                                       # Caso seja o último ciclo
          session_hash = {
                  "duration": current_duration,
                  "pages": out_pages,
                  "startTime": startTime }
           out_ary << session_hash
           out_pages = []                              # limpar variaveis
           startTime = 0                               #
      end
    end
  end
  return out_ary
end

################################### FUNÇÃO PRINCIPAL #################################
def session_analyzer(input_json)
  result = {} 
  input_json['events'].map{|item| item['visitorId']}.uniq.map{|key| result[key]=[]}
  ###=> result = {{key}=>[], {key2}=>[]}

  ### iterar as hashes de input_json e adicionar aos array de cada key de result url e timestamp
  ### {"d1177368-2310-11e8-9e2a-9b860a0d9039"=>[{"/pages/a-big-river"=>1512754583000}, {"/pages/a-small-dog"=>1512754631000}, {"/pages/a-big-river"=>1512754436000}], 
  ###  "f877b96c-9969-4abc-bbe2-54b17d030f8b"=>[{"/pages/a-big-talk"=>1512709065294}, {"/pages/a-sad-story"=>1512711000000}, {"/pages/a-sad-story"=>1512709024000}]}
  input_json['events'].map{|item| item}.each do |hsh|
    result[hsh['visitorId']] << { hsh['url']=>hsh['timestamp']}
  end
  
  output = {'sessionByUser' =>  {} }   # inicializar variavel de output

  result.each do |k, v|  
    output['sessionByUser'][k] = v.sort_by{ |hsh| hsh.values }
    ### estruturando o output e organizando(sort) os timestamps em ordem crescente
  end
  
  ### gerando o output quase pronto com uma última iteração
  output['sessionByUser'].each do |user, data|
    output['sessionByUser'][user] = time_session_manager_2(data)
  end
  
  ### Finalizando o output colocando as chaves (User) em ordem decrescente alfabética
  output['sessionByUser'] = output['sessionByUser'].sort_by{|k, v| k}.reverse
  print output
end

######################## EXECUÇÃO ###############################################
file = File.open('input') # Abre o arquivo (input)
file_data = file.read     # armazena conteudo em string
session_analyzer(session_parser(file_data)) # chama a função principal
file.close                # fecha o arquivo de input

######################### FIM DO PROGRAMA ##########################
