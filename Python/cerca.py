#!/usr/bin/python3
# -*- coding: utf-8 -*-

import sys
import urllib.request
import xml.etree.ElementTree as ET
import math
import argparse
import unicodedata
import codecs
from datetime import timedelta, datetime
from ast import literal_eval

#Funcions

def maxim(a,b):
	if a >= b:
		return a
	else:
		return b


def carregaParametres():
	parser = argparse.ArgumentParser()
	parser.add_argument('--lan',nargs='?',choices=['cat','es','en','fr'],default='cat')
	parser.add_argument('--key',type=str)
	return parser.parse_args()
	
def carregaUrls(args):
	xml1 = "http://wservice.viabicing.cat/v1/getstations.php?v=1"
	if args.lan == 'cat':
		xml2 = "http://www.bcn.cat/tercerlloc/pits_opendata.xml"
	elif args.lan == 'en':
		xml2 = "http://www.bcn.cat/tercerlloc/pits_opendata_en.xml"
	elif args.lan == 'es':
		xml2 = "http://www.bcn.cat/tercerlloc/pits_opendata_es.xml"
	else:
		xml2 = "http://www.bcn.cat/tercerlloc/pits_opendata_fr.xml"
	
	return xml1, xml2

def carregaRoots(xml1,xml2):
	a = urllib.request.urlopen(xml1)
	tree1 = ET.parse(a)
	root1 = tree1.getroot()
	b = urllib.request.urlopen(xml2)
	tree2 = ET.parse(b)
	root2 = tree2.getroot()	
	return root1, root2
	
	
def normalitza(par):	#Funcio que normalitza strings (minuscules i sense accents)
   return (''.join(c for c in unicodedata.normalize('NFD', par)
                  if unicodedata.category(c) != 'Mn')).lower()
	
	
def evalExpr(keys, opt, name, content, location):	#funcio que resol les expresions booleanes
	if keys == None:								#opt = 0 -> mirem a name + location
		return True									#opt = 1 -> mirem a name
	elif isinstance(keys, tuple):					#opt = 2 -> mirem a content
		correct = 1									#opt = 3 -> mirem a location
		for key in keys:
			if not evalExpr(key, opt, name, content, location):
				correct = 0
				break
		return (correct == 1)      
	elif isinstance(keys, list):
		correct = 0
		for key in keys:
			if evalExpr(key, opt, name, content, location):
				correct = 1
				break
		return (correct == 1)      
	elif isinstance(keys, dict):
		correct = 1
		for key in keys:
			if (key == "name" and not evalExpr(keys[key], 1, name, content, location)):
				correct = 0
				break
			elif (key == "content" and not evalExpr(keys[key], 2, name, content, location)):
				correct = 0
				break
			elif (key == "location" and not evalExpr(keys[key], 3, name, content, location)):
				correct = 0
				break
		return (correct == 1)
	else:
		if opt == 1:
			return (normalitza(keys) in normalitza(name))
		elif opt == 2:
			return (normalitza(keys) in normalitza(content))
		elif opt == 3:
			return (normalitza(keys) in normalitza(location))
		else:
			return (normalitza(keys) in normalitza(name+" "+location))
			
			
def recorreXML(xml1,xml2,keys):
	puntsInteres = 0
	root1, root2 = carregaRoots(xml1,xml2)
	llistacurta = []
	llistallarga = []
	for event in root2.iter('row'):
		name = event.find('name').text
		address = event.find('address').text
		location = address
		district = event.find('district')
		if district != None:
			location = location + district.text
		barri = event.find('addresses').find('item').find('barri')
		if barri != None:
			location = location + barri.text
		content = event.find('content').text
		if (evalExpr(keys,0,name,content,location)):
			puntsInteres = puntsInteres + 1
			descCurta = event.find('custom_fields').find('descripcio-curta-pics').text
			gmapx = event.find('gmapx').text
			gmapy = event.find('gmapy').text
			listaSlots, listaBicis = bicingStations(root1,float(gmapx),float(gmapy))
			llistacurta.append((name,address,content,float(gmapx),float(gmapy),listaSlots,listaBicis))
			llistallarga.append((name,address,descCurta,float(gmapx),float(gmapy),listaSlots,listaBicis))
	if puntsInteres > 2:
		return llistallarga
	else:
		return llistacurta


def bicingStations(root,gmapx,gmapy):
	listaBicis = []
	listaSlots = []
	for station in root.iter('station'):
		slots = station.find('slots').text
		bicis = station.find('bikes').text
		lat = float(station.find('lat').text)
		longi = float(station.find('long').text)
		dist = distancies(gmapx,gmapy,lat,longi)
		dist = round(dist,2)
		ident = station.find('id').text
		if (int(slots,10) > 0 and dist <= 500):
			listaSlots.append((int(ident),int(slots),dist))
		if (int(bicis,10) > 0 and dist <= 500):
			listaBicis.append((int(ident),int(bicis),dist))
	listaSlots.sort(key=lambda tup: tup[1],reverse=True)
	listaBicis.sort(key=lambda tup: tup[1],reverse=True)
	if len(listaSlots) > 5:
		listaSlots = listaSlots[0:5]
	if len(listaBicis) > 5:
		listaBicis = listaBicis[0:5]
	return listaSlots, listaBicis

def taulaHTML(lista):
	arxiu = codecs.open('salida.html','w','utf-8')
	arxiu.write('<html><head><meta charset="UTF-8"></head><head><title>Resultados Cerca.py</title></head><body><h4>Punts de interés</h4> <table border="2px" style="text-align: center;">')
	arxiu.write('<tr><th>Nom</th><th>Adreça</th><th>Descripció</th><th>Station</th><th>Slots Bicis</th><th>Distancia</th><th>Station</th><th>Bicis Lliures</th><th>Distancia</th>')

	for elem in lista:
		lenSlots = len(elem[5])
		lenBicis = len(elem[6])
		size = maxim(lenSlots,lenBicis)
		arxiu.write('<tr><td rowspan="'+str(size)+'">'+str(elem[0])+'</td><td rowspan="'+str(size)+'">'+str(elem[1])+'</td><td rowspan="'+str(size)+'">'+str(elem[2])+'</td>')
		if size == 0:
			arxiu.write('<td>'+"-"+'</td><td>'+"-"+'</td><td>'+"-"+'</td><td>'+"-"+'</td><td>'+"-"+'</td><td>'+"-"+'</td>')
		for it in range(size):
			if it != 0:
				arxiu.write('</tr><tr>')
				
			if it < (len(elem[5])):
				arxiu.write('<td>'+str(elem[5][it][0])+'</td><td>'+str(elem[5][it][1])+'</td><td>'+str(elem[5][it][2])+'</td>')
			else:
				arxiu.write('<td>'+"-"+'</td><td>'+"-"+'</td><td>'+"-"+'</td>')
			if it < (len(elem[6])):
				arxiu.write('<td>'+str(elem[6][it][0])+'</td><td>'+str(elem[6][it][1])+'</td><td>'+str(elem[6][it][2])+'</td>')
			else:
				arxiu.write('<td>'+"-"+'</td><td>'+"-"+'</td><td>'+"-"+'</td>')
		arxiu.write('</tr>')
	arxiu.write('</table></body></html>')		


def distancies(Lat1,Long1,Lat2,Long2):
	Lat1 = (Lat1*3.141592654)/180.0
	Long1 = (Long1*3.141592654)/180.0
	Lat2 = (Lat2*3.141592654)/180.0
	Long2 = (Long2*3.141592654)/180.0
	Distancia = 6371 * math.acos(math.cos(Lat1) * math.cos(Lat2) * \
				math.cos(Long2 - Long1) + math.sin(Lat1) * \
				math.sin(Lat2)) * 1000
	return Distancia

#main

args = carregaParametres()
keys = literal_eval(args.key)
xml1, xml2 = carregaUrls(args)
l = recorreXML(xml1,xml2,keys)
taulaHTML(l)
