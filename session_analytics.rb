#!/usr/bin/env ruby

require 'json'

### LE O ARQUIVO EM INPUT E ARMAZENA O CONTEUDO EM FORMA DE STRING
file = File.open('input')
file_data = file.read

### faz o parse da string lida do arquivo input
def session_parser(input_str)
  return JSON.parse(input_str)
end

def session_analyzer(input_json)
  result = {}

  ### result = {{key}=>[], {key2}=>[]} 
  input_json['events'].map{|item| item['visitorId']}.uniq.map{|key| result[key]=[]}
  
  ### iterar as hashes de input_json e adicionar aos array de cada key de result url e timestamp
  input_json['events'].map{|item| item}.each do |hsh|
    result[hsh['visitorId']] << { hsh['url']=>hsh['timestamp']}
  end
  print result
end

session_analyzer(session_parser(file_data))
