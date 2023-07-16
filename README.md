
# Akbank Final Project

Bu projede COBOL programımıza QSAM ve VSAM dosyalarını programımıza input olarak veriyoruz.

Bu dosyalarımızı oluşturmak için 
 
 -FNLFILEJ jcl dosyamızı çalıştırarak sağlıyoruz dosyalarımız data setlerimizle birlikte oluşuyor.

Dosyalarımız oluşturduktan sonra main programımızı çalıştırarak programımızı başlatıyoruz.

 -FNLPROJ jcl dosyamızı çalıştırarak programımızı başlatıyoruz.

Bu programımızın amaçı verdiğimiz inputlar ile oluşan VSAM dosyasında değişiklikler yapmak ve bu değişiklikleri OUT dosyamızda belirtmek.


## Özellikler

- Bu kısımda MAIN ve SUB frame COBOL dosyalarımı jcl de çalıştırmak için belirtiyoruz.

```
    //SUB EXEC IGYWCL

    //COBOL.SYSIN  DD DSN=&SYSUID..CBL(SUBFNL),DISP=SHR
    
    //LKED.SYSLMOD DD DSN=&SYSUID..LOAD(SUBFNL),DISP=SHR
    
    //MAIN EXEC IGYWCL
    
    //COBOL.SYSIN  DD DSN=&SYSUID..CBL(MAINFNL),DISP=SHR
    
    //LKED.SYSLMOD DD DSN=&SYSUID..LOAD(MAINFNL),DISP=SHR
```
- LINKAGE SECTION kullanarak main framden sub frame e verilerimizi iletiyoruz

- MAIN frame kısmında bu kod ile SUB frameimizi çağırıyoruz ve verilerimi alt programımıza iletiyoruz.
`
    CALL WS-SUBFNL USING WS-SUB-AREA.
`
- SUB frame kısmında da LINKAGE SECTION kısmında bu verilerimizi tanımlıyoruz.

```
    LINKAGE SECTION.
       01  LK-REC.
           05 LK-FUNC           PIC 9.
           05 LK-ID             PIC 9(5).
           05 LK-DVZ            PIC 9(3).
           05 LK-RC             PIC 9(2).
           05 LK-DATA.
               10 LK-WRONG-EXP  PIC X(30).
               10 LK-NAME-FROM  PIC X(15).
               10 LK-NAME-TO    PIC X(15).
               10 LK-SNAME-FROM PIC X(15).
               10 LK-SNAME-TO   PIC X(15).
```

- COBOL da evaluate yapısı bir dizi koşulu kontrol etmek ve buna bağlı olarak farklı işlemler gerçekleşmesini sağlayan yapıdır.

- Evaluate IF-THEN-ELSE ifadesi yerine kullanılabilir ve kodun okunabilirliğini arttırır.

```

           EVALUATE TRUE
               WHEN WS-OPEN
                    PERFORM 2000-OPEN
               WHEN WS-WRITE
                    PERFORM 3000-WRITE
               WHEN WS-UPDATE
                    PERFORM 4000-UPDATE
               WHEN WS-DELETE
                    PERFORM 5000-DELETE
               WHEN WS-READ
                    PERFORM 6000-READ
               WHEN WS-CLOSE
                    PERFORM 7000-CLOSE
               WHEN OTHER
                    MOVE 'WRONG FUNCTION CODE' TO LK-WRONG-EXP
           END-EVALUATE.
```

- WHEN OTHEN kısmı hiçbir koşul sağlanmazsa gerçekleşicek adımımızdır.


## Çalıştırma



```bash 
  FNLFILEJ.jcl dosyamızı derleyerek başlıyoruz
   - Bu adımda gerekli dosyalarımız oluşturuyoruz.
  FNLPROJ.jcl dosyamızı derleyerek ana programımızı çalıştırıyoruz
   - Bu adımda programımız çalışır ve gerekli değişiklikler VSAM dosyamızda sağlanır ve QSAM.OUT dosyamıza yapılan bütün işlemler kayıt edilir.
```
