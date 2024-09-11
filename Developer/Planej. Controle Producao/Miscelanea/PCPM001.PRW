#INCLUDE "totvs.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'TbiConn.Ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE 'fileio.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWMBrowse.ch'
#INCLUDE "ParmType.ch"

USER FUNCTION PCPM001()
    Local aFontes := {}
    Local aData
    Local aRet
    Local aType
    Local adados
  // Para retornar o nome do arquivo onde foi declarada a função
    Local aFile
  // Para retornar o número da linha no arquivo onde foi declarada a função
    Local aLine
  // Para retornar a data da última modificação do código fonte compilado
    Local aDate
  // Para retornar a hora da última modificação do código fonte compilado
    Local aTime    

    aFontes := GetSrcArray("*.PRW",3)
    aData := GetRpoLog(1)
    aRet := GetFuncArray('U_*', aType, aFile, aLine, aDate,aTime)

    adados:=GetAPOInfo("PCPM001")

RETURN
