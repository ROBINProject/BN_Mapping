# -*- mode: python -*-
a = Analysis(['verifyncfiles.py'],
             pathex=['C:\\Users\\Miguel\\Documents\\0 Versiones\\2 Proyectos\\BN_Mapping\\Maps_BN_python'],
             hiddenimports=[],
             hookspath=None,
             runtime_hooks=None)
pyz = PYZ(a.pure)
exe = EXE(pyz,
          a.scripts,
          a.binaries,
          a.zipfiles,
          a.datas,
          name='verifyncfiles.exe',
          debug=False,
          strip=None,
          upx=True,
          console=True )
