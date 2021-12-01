#!/usr/bin/env ruby

require 'json'

### LE O ARQUIVO EM INPUT E ARMAZENA O CONTEUDO EM FORMA DE STRING
file = File.open('input')
file_data = file.read

### faz o parse da string lida do arquivo input
def session_parser(input_str)
  return JSON.parse(input_str)
end

def time_session_manager_2(hashes)
  len = hashes.length - 1
  startTime = 0
  out_ary = []
  out_pages = []
  hashes.each.with_index do |hsh, i|
    if startTime == 0
      startTime = hsh.values[0]
    end
    out_pages << hsh.keys[0]
    if hsh.values[0] - startTime > 600000
      print i
      session_hash = {
      "duration": hashes[i-1].values[0] - startTime,
      "pages": out_pages.uniq,
      "startTime": startTime }
      out_ary << session_hash
      out_pages = []
      startTime = 0
      if i == len
        print "dentro do elsif"
        session_hash = {
        "duration": hsh.values[0] - startTime,
        "pages": out_pages.uniq,
        "startTime": startTime }
        out_ary << session_hash
        out_pages = []
        startTime = 0
      end
    elsif i == len
      print "dentro do elsif"
      session_hash = {
      "duration": hsh.values[0] - startTime,
      "pages": out_pages.uniq,
      "startTime": startTime }
      out_ary << session_hash
      out_pages = []
      startTime = 0
    end
  end
  return out_ary
end

### recebe um array de hashes com TIMESTAMPS, 
### calcula diferença de tempo e retorna um array de hashes estruturado
def time_session_manager(hashes)
  ### inicializaçao de variaveis uteis
  count = 0
  startTime = 0
  out_ary = []
  out_pages= []
  duration = 0
  last_duration = 0
  session_hash = {}

  ### iteração por cada hash do array
  hashes.each.with_index do |hsh, i|
    ### Se count é 0, o timestamp é o começo da sessao 
    if count == 0 
      startTime = hsh.values[0]
      count += 1
    end

    ### adicionar urls para um array
    out_pages << hsh.keys[0]

    ### armazenar duração de um ciclo anterior
    if i > 0
      last_duration = hashes[i-1].values[0] - startTime
    end

    ### atualizar a duração tempo atual - tempo de começo
    duration = hsh.values[0] - startTime
  
    session_hash = {
      "duration": duration,
      "pages": out_pages.uniq,
      "startTime": startTime }
    
    if duration > 600000   ### 10 min em milisec 
      count = 0
      session_hash[:duration] = last_duration
      out_ary << session_hash
      out_pages = []
      ### resetar os contadores de durações
      last_duration = 0
      duration = 0
    elsif i == hashes.length - 1
      out_ary << session_hash
      out_pages = []
      count = 0
      duration = 0
      last_duration = 0
    end
  end
  return out_ary
end



      
      


def session_analyzer(input_json)
  result = {}

  ### result = {{key}=>[], {key2}=>[]} 
  input_json['events'].map{|item| item['visitorId']}.uniq.map{|key| result[key]=[]}
  
  ### iterar as hashes de input_json e adicionar aos array de cada key de result url e timestamp
  ### {"d1177368-2310-11e8-9e2a-9b860a0d9039"=>[{"/pages/a-big-river"=>1512754583000}, {"/pages/a-small-dog"=>1512754631000}, {"/pages/a-big-river"=>1512754436000}], 
  ###  "f877b96c-9969-4abc-bbe2-54b17d030f8b"=>[{"/pages/a-big-talk"=>1512709065294}, {"/pages/a-sad-story"=>1512711000000}, {"/pages/a-sad-story"=>1512709024000}]}
  input_json['events'].map{|item| item}.each do |hsh|
    result[hsh['visitorId']] << { hsh['url']=>hsh['timestamp']}
  end
  
  output = {'sessionByUser' =>  {} }

  ### estruturando o output e organizando os timestamps em ordem crescente
  result.each do |k, v|
    output['sessionByUser'][k] = v.sort_by{ |hsh| hsh.values }
  end
  
  ### gerando o output final com uma última iteração
  output['sessionByUser'].each do |user, data|
    output['sessionByUser'][user] = time_session_manager_2(data)
  end

  print output
end

session_analyzer(session_parser(file_data))
