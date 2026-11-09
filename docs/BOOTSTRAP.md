# Demokratia — Documento di Bootstrap

> Stato: bozza v0.1 — documento vivo, da aggiornare man mano che il progetto prende forma.

## 1. Visione

Ridare ai cittadini un canale informativo diretto, cronologico e senza intermediazione algoritmica su ciò che accade nella propria città: manifestazioni, cortei, assemblee, dibattiti, raccolte firme, eventi sociali e culturali a sfondo civico.

## 2. Problema

- I social network sono oggi il canale principale con cui le persone vengono a sapere di eventi civici e politici, ma l'algoritmo di raccomandazione decide chi vede cosa: chi non segue già le pagine "giuste", o chi l'algoritmo penalizza, semplicemente non sa che un evento esiste.
- Questo produce un effetto bolla: partecipa chi è già dentro certi circuiti informativi, chi ne è fuori resta escluso — non per scelta, ma per un difetto strutturale del canale.
- Non esiste un canale neutrale, unico e affidabile per sapere "cosa succede in città" dal punto di vista civico/associativo/politico.

## 3. Missione

Costruire un'infrastruttura informativa civica, open source e no profit, dove:
- ogni cittadino può scoprire eventi rilevanti per la propria città/zona in ordine cronologico e geografico, non "per rilevanza algoritmica";
- ogni organizzazione (associazione, partito, comitato, sindacato, gruppo informale) ha lo stesso megafono di ogni altra: nessuno paga per apparire di più;
- iscriversi a un evento è un impegno esplicito dell'utente (non una inferenza del sistema), e genera promemoria puntuali.

## 4. Principi fondanti

Questi principi sono vincoli di progetto, non aspirazioni — ogni feature futura va valutata rispetto a questi:

1. **Nessun ranking opaco.** Il feed è cronologico e/o geografico, filtrabile esplicitamente dall'utente. Nessun algoritmo di "engagement" decide cosa mostrare per primo.
2. **Parità di visibilità.** Un'organizzazione con 10 iscritti e una con 10.000 hanno lo stesso trattamento nel sistema. Nessuna promozione a pagamento, nessun boost.
3. **Neutralità politica.** La piattaforma non prende posizione sui contenuti; modera solo per illegalità, incitamento alla violenza, spam, contenuti falsi/ingannevoli sui fatti dell'evento (data/luogo/organizzatore).
4. **Dati minimi, nessuna profilazione pubblicitaria.** Non si vendono dati, non si fa ad-tech, non si traccia il comportamento oltre a ciò che serve a far funzionare notifiche e reminder.
5. **Open source per default.** Codice e decisioni di roadmap sono pubblici e verificabili — la fiducia nel canale nasce dalla sua trasparenza, non dal brand.
6. **No profit.** Il progetto non è finanziato da vendita dati o advertising. Sostenibilità tramite donazioni, grant, volontariato (vedi §12).

## 5. Utenti e ruoli

| Ruolo | Descrizione | Può fare |
|---|---|---|
| **Cittadino** | Utente base, iscritto con un account personale | Seguire città/zone e categorie, iscriversi a eventi, ricevere reminder/notifiche, salvare eventi, segnalare contenuti, creare eventi come singolo cittadino (con limiti anti-spam) |
| **Organizzazione** | Associazione, partito, comitato, sindacato, gruppo informale, ente locale | Tutto ciò che fa il Cittadino + profilo pubblico dell'organizzazione, pubblicazione eventi a nome dell'organizzazione, statistiche di base sui propri eventi (adesioni, non dati personali dei singoli) |
| **Moderatore** | Volontario/staff con permessi di moderazione | Gestire coda segnalazioni, sospendere contenuti che violano le regole (non per opinione), non ha potere editoriale sui contenuti legittimi |
| **Admin/Maintainer** | Team tecnico del progetto | Gestione infrastruttura, configurazione, nessun accesso privilegiato ai dati oltre il necessario per operare il servizio |

Un account Cittadino può in qualunque momento richiedere la creazione di un profilo Organizzazione collegato (many-to-many: una persona può amministrare più organizzazioni; un'organizzazione può avere più amministratori).

## 6. Funzionalità core (MVP)

### Onboarding
- Registrazione cittadino (email o numero di telefono + password, oppure OAuth in futuro)
- Selezione città/zona di residenza o interesse (multi-selezione possibile fin da subito, per chi segue più città)
- Selezione categorie di interesse iniziali (manifestazione, corteo, assemblea pubblica, dibattito/incontro, raccolta firme, evento culturale civico, sciopero, altro) — usata solo per pre-filtrare il feed, mai per profilazione esterna

### Feed
- Lista cronologica/geografica degli eventi futuri nella città/zone seguite
- Filtri espliciti: intervallo di date, categoria, organizzatore, distanza
- Nessun contenuto sponsorizzato, nessun "consigliato per te" algoritmico

### Evento
- Creazione evento: titolo, descrizione, categoria, data/ora inizio (ed eventuale fine), luogo (indirizzo + coordinate/mappa), organizzatore, immagine di copertina opzionale, link esterni opzionali (sito, comunicato)
- Pagina di dettaglio evento: tutte le info + pulsante "Parteciperò" / "Mi interessa" + mappa + condivisione (deep link)
- Modifica/cancellazione evento da parte di chi l'ha creato o dell'organizzazione
- Storico eventi passati (trasparenza: cosa è successo davvero)

### Iscrizione e notifiche
- Iscrizione a un evento → il cittadino riceve promemoria configurabili (es. 1 settimana prima, 1 giorno prima, 1 ora prima — soglie personalizzabili in futuro)
- Notifiche push (mobile) per: promemoria eventi iscritti, nuovi eventi pubblicati da organizzazioni seguite, modifiche/cancellazioni a eventi a cui si è iscritti
- Centro notifiche in-app con storico

### Organizzazioni
- Creazione profilo organizzazione: nome, descrizione, categoria/ambito, città di riferimento, link esterni, logo
- Pagina pubblica organizzazione: eventi passati e futuri, numero di follower (aggregato, non lista pubblica delle persone)
- "Segui organizzazione" → notifica su ogni nuovo evento pubblicato

### Moderazione (essenziale fin dall'MVP)
- Segnalazione di un evento (spam, contenuto illegale, informazioni false su data/luogo, incitamento alla violenza)
- Coda di moderazione per i volontari/staff
- Rate limiting sulla creazione eventi per singolo cittadino (anti-spam), nessun limite artificioso per organizzazioni verificate

## 7. Funzionalità future (v2+, non bloccanti per l'MVP)

- Mappa con cluster di eventi ("cosa succede vicino a me oggi")
- Discussioni/commenti per evento (con moderazione rinforzata, essendo superficie a rischio abusi)
- Verifica organizzazioni (badge, per distinguere entità reali da account creati ad-hoc) — senza che questo dia priorità nel feed, solo trasparenza
- Statistiche pubbliche aggregate e anonime (open data: quanti eventi per città/mese/categoria)
- API pubbliche in sola lettura (chiunque può costruire strumenti sopra ai dati aperti degli eventi)
- Esportazione/integrazione calendari esterni (iCal, Google Calendar)
- Web app oltre all'app mobile
- Multi-lingua, multi-paese
- Modalità "evento sensibile" (visibilità ritardata/ristretta per contesti dove la sicurezza dei partecipanti è a rischio)

## 8. Cosa il progetto NON deve fare (non-goals espliciti)

- Nessun algoritmo di raccomandazione basato su engagement/tempo-in-app
- Nessuna pubblicità, nessuna vendita/condivisione dati con terzi
- Nessuna moderazione basata sull'opinione politica espressa (si modera solo per illegalità/violenza/spam/falsità sui fatti oggettivi dell'evento)
- Nessun meccanismo "a pagamento per più visibilità"
- Nessun dark pattern per aumentare il tempo speso in app (l'app deve essere utile, non "avvincente")

## 9. Architettura ad alto livello

```
[ Flutter App (iOS/Android) ]  <-- REST/GraphQL API -->  [ Backend Python ]  <--> [ DB ]
                                                                |
                                                                +--> [ Servizio notifiche push (FCM/APNs) ]
                                                                +--> [ Scheduler reminder ]
                                                                +--> [ Servizio geo/ricerca ]
```

### 9.1 Responsabilità del Frontend (Flutter)

Il FE è responsabile di tutto ciò che è esperienza utente e stato locale; non contiene logica di business critica (quella vive nel BE).

- **UI e navigazione**: onboarding, feed, dettaglio evento, creazione/modifica evento, profilo organizzazione, centro notifiche, profilo utente/impostazioni
- **Autenticazione lato client**: gestione token (storage sicuro, refresh token), stato di login persistente
- **Geolocalizzazione**: richiesta permessi, posizione per filtro "vicino a me" e per precompilare la mappa in creazione evento
- **Notifiche push**: registrazione device token (FCM/APNs), gestione permessi, deep link dalla notifica alla schermata evento
- **Cache/offline-first leggero**: mostrare l'ultimo feed noto e gli eventi salvati anche offline; sync al ritorno online
- **Validazione form lato client**: campi obbligatori, formati data/ora, dimensione immagini — come UX, non come unica linea di difesa (il BE rivalida sempre)
- **Gestione stato**: stato locale dell'app (sessione, filtri feed attivi, bozze di eventi in creazione)
- **Accessibilità**: dimensioni testo dinamiche, contrasto, supporto screen reader — coerente con l'obiettivo di essere un canale davvero inclusivo
- **Deep linking**: condivisione di un evento tramite link che apre direttamente la schermata di dettaglio (anche se l'app non è installata → fallback a pagina web/store)

### 9.2 Responsabilità del Backend (Python)

Il BE è responsabile della logica di business, della sicurezza dei dati e dell'affidabilità delle notifiche.

- **API** (REST o GraphQL — da decidere in fase tecnica): autenticazione/autorizzazione, CRUD eventi, CRUD organizzazioni, iscrizioni/interessi, segnalazioni
- **Autenticazione e ruoli**: gestione account, permessi per ruolo (cittadino/organizzazione/moderatore/admin), amministratori multipli per organizzazione
- **Motore geo/ricerca**: query per città/zona/raggio, filtri per categoria/data/organizzatore, ordinamento cronologico esplicito (nessun ranking implicito)
- **Scheduling e notifiche**: job che calcola quando inviare i reminder (1 settimana/1 giorno/1 ora prima, configurabile), dispatch verso servizio push, gestione retry/fallimenti
- **Moderazione**: coda segnalazioni, stato di un evento (pubblicato/sospeso/rimosso), audit log delle azioni di moderazione (trasparenza interna)
- **Anti-abuso**: rate limiting su creazione eventi/segnalazioni per singolo account, rilevamento pattern di spam
- **Gestione organizzazioni**: creazione, amministratori multipli, eventuale verifica futura
- **Privacy/GDPR**: minimizzazione dati raccolti, cancellazione account e diritto all'oblio, nessun dato venduto o condiviso con terzi, cifratura dati sensibili a riposo
- **Open data (v2)**: endpoint pubblici in sola lettura per dati aggregati/eventi pubblici, pensati fin da subito nel modello dati anche se esposti più avanti

## 10. Modello dati (bozza concettuale)

Entità principali e relazioni chiave (dettaglio schema DB rimandato alla fase tecnica):

- **User** (Cittadino): id, email/telefono, password hash, città/zone seguite, categorie di interesse, ruolo
- **Organization**: id, nome, descrizione, categoria, città di riferimento, admin (N:M con User), verificata (bool, v2)
- **Event**: id, titolo, descrizione, categoria, data/ora inizio-fine, luogo (indirizzo + coordinate), creato_da (User o Organization), stato (pubblicato/sospeso/rimosso/cancellato), immagine copertina, link esterni
- **Subscription/Interest**: User ↔ Event ("parteciperò"/"mi interessa"), con preferenze di reminder
- **Follow**: User ↔ Organization
- **Notification**: id, User, tipo (reminder/nuovo evento/modifica/cancellazione), stato (inviata/letta), riferimento a Event
- **Report**: id, segnalante, Event/Organization segnalato, motivo, stato (in coda/risolto), esito
- **City/Area**: id, nome, confini geografici (per query e filtro)

## 11. Governance del progetto open source

Da definire in dettaglio, ma linee guida iniziali:

- Licenza open source permissiva o copyleft (da scegliere — es. AGPL-3.0 per garantire che eventuali fork/hosting derivati restino aperti, coerente con lo spirito no profit)
- `CONTRIBUTING.md` e `CODE_OF_CONDUCT.md` fin dalle prime fasi pubbliche
- Decisioni di roadmap discusse pubblicamente (issue tracker), non a porte chiuse
- Nessuna singola organizzazione/partito ha voce in capitolo privilegiata sulle decisioni tecniche o di prodotto — il team di maintainer è tecnico e neutrale

## 12. Sostenibilità economica

Essendo no profit e senza pubblicità/vendita dati, i costi (hosting, invio notifiche push, dominio) vanno coperti tramite:
- Donazioni (individui, eventualmente fondazioni allineate ai principi del progetto)
- Grant per progetti civici/open source (es. fondi per innovazione civica, media literacy, partecipazione democratica)
- Volontariato per sviluppo e moderazione

Va evitato qualunque sponsor/finanziatore che possa creare conflitto con il principio di neutralità politica (§4.3).

## 13. Rischi e sfide aperte

- **Effetto network**: un'app di eventi civici è utile solo se le organizzazioni la usano davvero — serve una strategia di adozione iniziale (partire da una città pilota, coinvolgere attivamente le prime organizzazioni)
- **Percezione di neutralità**: qualunque decisione di moderazione rischia di essere letta come schieramento politico — servono regole di moderazione scritte, pubbliche e applicate in modo dimostrabilmente uniforme
- **Organizzazioni fake/spam**: bilanciare apertura ("chiunque può postare") con affidabilità delle informazioni (data/luogo corretti)
- **Sicurezza dei partecipanti**: in alcuni contesti la visibilità pubblica di un evento (es. corteo non autorizzato) può esporre a rischio i partecipanti — da considerare per feature future (v2, "evento sensibile")
- **Retention senza dark pattern**: il valore dell'app deve venire dall'utilità reale (essere informati in tempo), non da meccaniche di coinvolgimento forzato

## 14. Metriche di successo (non vanity metrics)

- Numero di città attive con almeno N eventi/mese
- Percentuale di reminder consegnati in tempo utile (prima dell'evento)
- Numero di organizzazioni attive che pubblicano regolarmente
- Copertura: quota di eventi civici "reali" in una città che finiscono per essere pubblicati sulla piattaforma
- Esplicitamente NON si ottimizza per: tempo speso in app, sessioni giornaliere, scroll depth

## 15. Roadmap indicativa

1. **MVP (città pilota singola)**: onboarding, feed cronologico, creazione/iscrizione eventi, reminder base, profilo organizzazione semplice, moderazione manuale
2. **Beta multi-città**: estensione geografica, follow organizzazioni, centro notifiche completo, prime metriche di adozione
3. **v1 pubblica**: verifica organizzazioni, statistiche pubbliche aggregate, API open data in sola lettura
4. **v2+**: mappa eventi, discussioni moderate, modalità evento sensibile, multi-lingua

---

## Prossimi passi tecnici (non ancora decisi in questo documento)

- Scelta framework BE Python (es. FastAPI/Django), DB (relazionale + estensione geo tipo PostGIS), servizio notifiche push, hosting
- Definizione schema DB dettagliato e OpenAPI/GraphQL schema
- Design system Flutter (componenti condivisi tra le schermate del wireframe)
