# Elite Dangerous – Auto Landing Gear

**Autor : Revahar**

Automatisation du déploiement et du repli des trains d'atterrissage dans Elite Dangerous grâce à AutoHotkey v2.

Ce script permet de gérer automatiquement les trains d'atterrissage lors des phases d'approche, d'appontage et de décollage.

Il propose deux automatisations indépendantes :
- Le déploiement automatique des trains.
- Le repli automatique des trains.

Chaque utilisateur peut choisir les fonctions qu'il souhaite activer.

---

## Fonctionnalités

### Stations orbitales

/!\ Le déploiement automatique peut être désactivé dans les paramètres.

Pour les stations orbitales de type Coriolis, Orbis, Ocellus et Asteroid Base :

- Détection de la musique `Starport` dans le journal du jeu cette musique apparait dans le journal après le passage de la "boite aux lettres".
- Déploiement automatique des trains après un délai configurable.

### Autres stations et installations

Pour les Fleet Carriers, bases au sol, avant-postes et autres installations :

1. Le pilote demande l'autorisation d'appontage.
2. Le jeu enregistre l'événement `DockingGranted` dans son journal.
3. Le script surveille l'apparition du Mass Lock.
4. Dès que le Mass Lock apparaît, un délai configurable est lancé.
5. Les trains d'atterrissage sont automatiquement déployés à la fin de ce délais.

### Repli automatique

/!\ Le repli automatique peut être désactivé dans les paramètres.

Lors des événements suivants :
- `Undocked` : les trains sont automatiquement rentrés.
- `DockingCancelled` : les trains sont automatiquement rentrés.

---

## Prérequis

- AutoHotkey v2.0 ou version ultérieure.
- Le journal et le fichier `Status.json` d'Elite Dangerous accessibles sur le PC.

### Télécharger AutoHotkey

https://www.autohotkey.com/download/

Attention : ce script est conçu pour AutoHotkey v2. Il n'est pas compatible avec AutoHotkey v1 sans adaptation.

---

## Installation

1. Télécharger et installer AutoHotkey v2.
2. Télécharger le fichier `AutoLandingGear.ahk`.
3. Placer le script dans le dossier de votre choix.
4. Vérifier les paramètres du script si nécessaire.
5. Double-cliquer sur le script ou faire un clic droit → Ouvrir avec AutoHotkey.
6. Lancer Elite Dangerous. 

Le script surveille automatiquement le journal du jeu.

Aucune modification des fichiers du jeu n'est nécessaire.

---

## Configuration

Les paramètres modifiables se trouvent au début du script.

; Touche clavier affectée aux trains
GearKey := "g"

; Délai Starport (en millisecondes)
DeployDelay := 1500

; Délai après apparition du Mass Lock
MassLockDelay := 2500

; Fréquence de surveillance du Mass Lock
MassLockPollDelay := 500

; Automatiser le déploiement des trains
AutoDeploy := true

; Automatiser le repli des trains
AutoRetract := true
```

### Paramètres disponibles

| Paramètre | Description | Valeur par défaut |
|---|---|---|
| `GearKey` | Touche configurée dans Elite Dangerous pour les trains | `g` |
| `DeployDelay` | Délai après la détection de Starport | 1500 ms |
| `MassLockDelay` | Délai après apparition du Mass Lock | 2500 ms |
| `MassLockPollDelay` | Fréquence de surveillance du Mass Lock | 500 ms |
| `AutoDeploy` | Active ou désactive le déploiement automatique | `true` |
| `AutoRetract` | Active ou désactive le repli automatique | `true` |

Les délais sont exprimés en millisecondes.

Exemple : `2500` correspond à 2,5 secondes.

---

## Choix du mode d'automatisation

Les deux options sont indépendantes.

| AutoDeploy | AutoRetract | Fonctionnement |
|---|---|---|
| `true` | `true` | Déploiement et repli automatiques |
| `false` | `true` | Déploiement manuel, repli automatique |
| `true` | `false` | Déploiement automatique, repli manuel |
| `false` | `false` | Déploiement et repli manuels |

Pour désactiver une fonction, remplacer `true` par `false`.

Exemple pour conserver uniquement le repli automatique :

AutoDeploy := false
AutoRetract := true


---

## Fonctionnement technique

Le script utilise deux sources de données du jeu :

### Journal Elite Dangerous

Le journal permet de détecter les événements :
- `DockingGranted`
- `DockingCancelled`
- `Undocked`
- `MusicTrack: Starport`

### Status.json

Le fichier `Status.json` permet de lire l'état réel des trains d'atterrissage et du Mass Lock.

Le script utilise ces informations pour éviter de commander inutilement les trains lorsqu'ils sont déjà dans le bon état.

Le dossier surveillé par défaut est :

%USERPROFILE%\Saved Games\Frontier Developments\Elite Dangerous

---

## Conseils d'utilisation

- Vérifier que la touche affectée aux trains dans le jeu correspond à `GearKey`.
- Le jeu doit être actif au moment où le script envoie une commande clavier.
- Si vous modifiez les paramètres, relancer le script pour prendre en compte les changements.
- Le déploiement automatique reste facultatif : il est possible de conserver une gestion manuelle des trains.

---

## Dépannage

### Les trains ne sortent pas

Vérifier :
- Que `AutoDeploy := true`.
- Que la touche `GearKey` correspond à la configuration du jeu.
- Que le jeu est actif au moment du déclenchement et au 1er plan.
- Que le journal et `Status.json` sont accessibles.

### Les trains ne rentrent pas automatiquement

Vérifier que :

AutoRetract := true

### Le script ne se lance pas

Vérifier que :
- AutoHotkey v2 est installé.
- Le script est bien exécuté avec AutoHotkey v2.
- Le chemin du dossier Saved Games est correct.

---

## Tests réalisés

Les tests fonctionnels ont été effectués sur :

- Fleet Carrier
- Base au sol
- Avant-poste
- Station orbitale

Les différents mécanismes de déploiement et de repli ont été vérifiés dans ces environnements.

---

## Auteur

**Revahar**
Me contacter :
- Discord (MP) : Revahar
- Mail : revahar@hotmail.com

