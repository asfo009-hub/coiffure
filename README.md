# Liste des stagiaires — saisie partagée en ligne

Petite application web (un seul fichier `index.html`, sans installation ni compilation) qui remplace le `localStorage` du générateur initial par une **base Supabase en ligne**. Plusieurs personnes peuvent saisir depuis différents appareils : les données sont partagées et mises à jour en temps réel. L'impression / export PDF A4 paysage du fichier d'origine est conservée.

**Application déployée :** https://coiffuresaisie.vercel.app/

## Fichiers

- `index.html` — l'application à ouvrir / héberger.
- `supabase/schema.sql` — script de création des tables à exécuter une fois dans Supabase.
- `README.md` — ce mode d'emploi.

## 1. Créer la base Supabase

1. Créez un compte et un projet sur https://supabase.com/dashboard (offre gratuite suffisante).
2. Dans le projet, ouvrez **SQL Editor** → **New query**.
3. Copiez tout le contenu de `supabase/schema.sql`, collez-le et cliquez sur **Run**.
4. Ouvrez **Project Settings** → **API** et notez :
   - **Project URL** (ex. `https://abcdefgh.supabase.co`)
   - **anon key** (ou *publishable key* `sb_publishable_...`)

## 2. Brancher l'application

### Option A — pour tout le monde (recommandée pour un lien partagé)

Ouvrez `index.html` dans un éditeur de texte et remplacez en haut du script :

```js
const SUPABASE_URL = 'https://abcdefgh.supabase.co';
const SUPABASE_ANON_KEY = 'votre_cle_anon_ou_publishable';
```

Hébergez ensuite le fichier (voir étape 3). Toutes les personnes qui ouvrent le lien utilisent la même base, sans rien configurer.

### Option B — configuration rapide sur un seul appareil

Ouvrez `index.html`, cliquez sur **⚙️ Configuration**, collez l'URL et la clé, puis **Enregistrer et connecter**. La configuration est mémorisée dans ce navigateur uniquement. Pratique pour tester avant de modifier le fichier.

## 3. Héberger et partager

Déposez `index.html` sur un hébergeur statique, par exemple :

- **Netlify** : https://app.netlify.com/drop (glisser le dossier, lien obtenu immédiatement)
- **Vercel**, **GitHub Pages**, ou votre hébergeur existant (OVH, Ionos, etc.)

Partagez ensuite l'URL obtenue. Il s'agit bien d'une application statique : aucun serveur Node/Python n'est nécessaire.

> Pour un test local, vous pouvez ouvrir `index.html` directement dans le navigateur, mais le lien partagé doit pointer vers une version hébergée.

## Utilisation

- **＋ Ajouter un stagiaire** : la ligne est créée immédiatement dans la base (même vide).
- Saisie dans les champs : enregistrement automatique après ~0,5 s (infos générales : ~0,6 s).
- **↻ Actualiser** : recharge depuis la base. Un rafraîchissement automatique a lieu toutes les 15 s en secours du temps réel.
- **Imprimer / Exporter en PDF** : même document A4 paysage que le fichier d'origine.
- **Exporter / Importer les données** : fichier JSON compatible avec l'ancien générateur. L'import **remplace** la liste en ligne (confirmation demandée).
- **Vider la liste** : supprime tous les stagiaires puis recrée une ligne vide.

Le badge en haut indique l'état : **En ligne**, **Synchronisation…**, **Configuration requise** ou **Connexion échouée**.

## Sécurité — important

Avec le choix « lien partagé sans login », la clé anon est publique (elle est visible dans le fichier) et les policies SQL autorisent **tout le monde** à lire, modifier et supprimer les données. C'est le fonctionnement le plus simple, mais :

- ne mettez **pas** de données sensibles (CIN complet, etc.) dans un projet configuré ainsi ;
- le lien donne les mêmes droits à toutes les personnes qui le reçoivent ;
- pour restreindre l'accès, il faudra ajouter Supabase Auth (comptes utilisateurs) et remplacer les policies `anon_all_*` par des policies basées sur `auth.uid()`.

À noter : les projets Supabase gratuits sont mis en pause après environ une semaine d'inactivité ; rouvrez le dashboard pour les réactiver si besoin.

## Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| `Configuration requise` | URL ou clé absente | Étape 2 (configuration ou constantes dans le fichier) |
| `relation "stagiaires" does not exist` | Script SQL non exécuté | Réexécuter `supabase/schema.sql` dans le SQL Editor |
| `Invalid API key` | Clé erronée ou ancienne | Recopier la clé depuis Project Settings → API |
| Les modifications d'un autre appareil n'apparaissent pas | Temps réel non actif | Vérifier la fin de `schema.sql` (publication `supabase_realtime`) ; le bouton **Actualiser** fonctionne quand même |
| `Librairie indisponible` | CDN bloqué / hors ligne | Vérifier la connexion Internet puis recharger |
