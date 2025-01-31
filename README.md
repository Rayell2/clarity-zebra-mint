# ZebraMint

A Stacks blockchain platform for minting personalized NFTs. Users can create unique NFTs with custom metadata including name, description, image URI, and royalty settings.

## Features
- Mint new NFTs with custom metadata (all fields required)
- Set royalty percentages for secondary sales (0-50%)
- Transfer NFTs between users
- View NFT metadata and ownership information
- Update NFT metadata (owner only)
- Burn NFTs permanently
- Track creator royalty information

## Contract Details
The smart contract implements SIP-009 NFT standard and includes:
- NFT minting functionality with royalty settings and metadata validation
- Metadata storage and retrieval with creator tracking
- Transfer capabilities with burned token validation
- Owner-only metadata updates
- Token burning mechanism
- Royalty information tracking

## Metadata Validation
- All metadata fields (name, description, image URI) must be non-empty
- Empty metadata fields will result in transaction failure
- Validation occurs during minting and metadata updates

[Rest of README remains unchanged...]
