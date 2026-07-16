# 🌍 SEN RELAIS - Votre Guichet Unique au Sénégal

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Netlify](https://img.shields.io/badge/Deployed-Netlify-00C7B7?style=for-the-badge&logo=netlify&logoColor=white)

**La Super App qui révolutionne les services au Sénégal** 🇸🇳

[🌐 Site Live](https://sen-relais.netlify.app) • [📖 Documentation](#-documentation) • [🐛 Signaler un bug](https://github.com/votre-user/sen_relais/issues)

</div>

---

## 📖 À propos

**SEN RELAIS** est une **Super Application web** conçue pour centraliser et simplifier l'accès à plusieurs services essentiels au Sénégal. Elle s'adresse aux particuliers, à la diaspora et aux professionnels qui cherchent une solution unique pour leurs besoins quotidiens.

### 🎯 Notre Mission

> *Offrir à chaque Sénégalais un guichet unique, moderne et sécurisé, pour accéder aux services de voyage, immobilier, assurance et bien plus — le tout depuis une seule application.*

---

## ✨ Fonctionnalités

### 🛫️ Module Voyage & Billetterie
- Recherche de vols en temps réel
- Réservation de billets d'avion
- Paiement sécurisé via Wallet intégré
- Historique complet des réservations
- Gestion des statuts (Confirmée, Annulée, Remboursée)

### 🏠 Module Immobilier (Mboro)
- Catalogue d'appartements disponibles
- Filtres par quartier (Louis Lassere, Diameguene, TAÏBA-ICS)
- Système de réservation en ligne
- Paiement loyer + caution via Wallet
- Gestion admin complète (prix, photos, disponibilité)
- Calcul automatique du Chiffre d'Affaires

### 🛡️ Module Assurance
- Assurance Voyage
- Assurance Santé
- Assurance Auto
- Souscription en ligne
- Historique des contrats
- Génération de références uniques

### 💰 Wallet Intégré
- Solde en temps réel
- Rechargement du compte
- Historique des transactions
- Paiement sécurisé pour tous les services
- Débit automatique lors des réservations

### 👤 Espace Personnel
- Profil utilisateur personnalisable
- Gestion des notifications (Email, Push, SMS)
- Changement de mot de passe sécurisé
- Accès rapide à toutes les réservations

### 📊 Dashboard Admin
- Vue d'ensemble avec **CA Total** (Vols + Immo + Assurances)
- Statistiques par pôle d'activité
- Gestion des utilisateurs (blocage, suppression)
- Gestion des appartements
- Suivi des réservations et assurances
- **Export CSV** des données
- Support **multi-admins** sécurisé

---

## 🛠️ Stack Technique

| Catégorie | Technologie |
|-----------|-------------|
| **Frontend** | Flutter 3.0+ (Web) |
| **Langage** | Dart 3.0+ |
| **Backend** | Supabase (PostgreSQL) |
| **Authentification** | Supabase Auth (JWT) |
| **Sécurité** | Row Level Security (RLS) |
| **Déploiement** | Netlify |
| **Graphiques** | fl_chart |
| **Formatage** | intl |

---

## 🏗️ Architecture du Projet

```
sen_relais/
├── lib/
│   ├── main.dart                    # Point d'entrée
│   ├── models/                      # Modèles de données
│   │   ├── user_model.dart
│   │   └── apartment_model.dart
│   ├── screens/                     # Écrans de l'application
│   │   ├── home_screen.dart
│   │   ├── flight_search_screen.dart
│   │   ├── real_estate_screen.dart
│   │   ├── apartment_booking_screen.dart
│   │   ├── insurance_choice_screen.dart
│   │   ├── my_insurances_screen.dart
│   │   ├── my_bookings_screen.dart
│   │   ├── my_apartment_bookings_screen.dart
│   │   ├── wallet_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── change_password_screen.dart
│   │   ├── dashboard_admin_screen.dart
│   │   └── apartment_management_screen.dart
│   └── services/                    # Services métier
│       ├── auth_service.dart
│       ├── admin_service.dart
│       └── real_estate_service.dart
├── web/                             # Fichiers web
├── build/                           # Build de production
├── pubspec.yaml                     # Dépendances
└── README.md                        # Ce fichier
```

---

## 🚀 Installation

### Prérequis
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- [Dart SDK](https://dart.dev/get-dart) (3.0+)
- Un compte [Supabase](https://supabase.com/)
- Git

### Étapes

1. **Cloner le dépôt**
```bash
git clone https://github.com/votre-user/sen_relais.git
cd sen_relais
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Configurer Supabase**
   - Créez un projet sur [Supabase](https://supabase.com/)
   - Récupérez votre URL et votre clé anon
   - Créez un fichier `.env` à la racine :

```env
SUPABASE_URL=https://votre-projet.supabase.co
SUPABASE_ANON_KEY=votre-cle-anon
```

4. **Configurer la base de données**
   - Exécutez les scripts SQL disponibles dans `/sql/` pour créer les tables
   - Configurez les politiques RLS (Row Level Security)

5. **Lancer l'application**
```bash
flutter run -d chrome --dart-define-from-file=.env
```

---

## 🔐 Sécurité

SEN RELAIS implémente plusieurs niveaux de sécurité :

- ✅ **Authentification JWT** via Supabase Auth
- ✅ **Row Level Security (RLS)** sur toutes les tables
- ✅ **Fonction `is_current_user_admin()`** anti-récursion
- ✅ **Vérification des rôles** pour chaque action admin
- ✅ **Protection contre les doublons** lors de l'inscription
- ✅ **Hash des mots de passe** (géré par Supabase)

---

## 📸 Captures d'Écran

<div align="center">

| Accueil | Dashboard Admin |
|:---:|:---:|
| ![Accueil](docs/screenshots/home.png) | ![Dashboard](docs/screenshots/dashboard.png) |

| Résidences Mboro | Wallet |
|:---:|:---:|
| ![Residences](docs/screenshots/residences.png) | ![Wallet](docs/screenshots/wallet.png) |

</div>

> 💡 *Les captures d'écran seront ajoutées prochainement*

---

## 📊 Statistiques du Projet

| Métrique | Valeur |
|----------|--------|
| 📱 Modules | 5 (Voyage, Immo, Assurance, Wallet, Transport) |
| 👥 Écrans | 20+ |
| 🔌 Services | 3 (Auth, Admin, Real Estate) |
| 🗄️ Tables SQL | 8+ |
| 🔐 Politiques RLS | 20+ |
| ⏱️ Temps de développement | ~3 mois |

---

## 🤝 Contribuer

Les contributions sont les bienvenues ! 🎉

1. Fork le projet
2. Créez votre branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

---

## 🗺️ Roadmap

- [ ] 🚚 Module Transport & Logistique
- [ ] 🔔 Notifications Push
- [ ] 🌙 Mode Sombre
- [ ] 📱 Application Mobile (iOS/Android)
- [ ] 💳 Intégration Orange Money / Wave
- [ ] 📊 Analytics avancés avec prévisions
- [ ] 🌍 Internationalisation (FR/EN/Wolof)

---

## 📞 Contact

**SEN RELAIS** - Votre guichet unique

- 📧 Email : [ndiayemoussa7816@gmail.com](mailto:ndiayemoussa7816@gmail.com)
- 📧 Email : [senrelais@gmail.com](mailto:senrelais@gmail.com)
- 📱 WhatsApp : [+221 76 390 66 87](https://wa.me/221763906687)
- 📱 WhatsApp : [+221 77 497 97 21](https://wa.me/221774979721)
- 🌐 Site web : [[appserelais.netlify.app](https://appsenrelais.netlify.app)

---

## 📄 Licence

Ce projet est la propriété de **SEN RELAIS**. Tous droits réservés.

---

## 🙏 Remerciements

- L'équipe **Flutter** pour leur framework exceptionnel
- **Supabase** pour leur backend puissant et flexible
- Tous nos **premiers utilisateurs** pour leurs retours précieux
- La **diaspora sénégalaise** qui nous inspire au quotidien

---

<div align="center">

**Fait avec ❤️ au Sénégal 🇸🇳**

*SEN RELAIS - Votre guichet unique pour tous vos besoins*

⭐ **N'oubliez pas de mettre une étoile si ce projet vous plaît !** ⭐

</div>
