^XA
^PW800
^LL400
^CI28
^LH0,0



/* ---- TOP SECTION (extra top padding) ---- */
^CF0,48
^FO35,75^FDAl Ghurair^FS

^CF0,40
^FO35,130^FDOrder:^FS
^FO150,130^FD2026-027^FS

^FO35,170^FDItem:^FS
^FO150,170^FDR06^FS

/* ---- PART + QTY (same block) ---- */
^CF0,35
^FO35,230^FDPart:^FS

/* Part description (wraps safely) */
^FO150,230^FB420,3,0,L,0^FDMain Sticker (P.Q. : 1)^FS


/* ---- QR CODE ---- */

^FO560,65^BQN,2,9
^FDQA,2026-027-R06-1^FS

/* ---- SN printed below QR (no label text) ---- */
^CF0,24
^FO560,280^FB200,2,0,C,0^FD2026-027-R06-1^FS

/* Print copies */
^PQ1,0,1,N
^XZ
