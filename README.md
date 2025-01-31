# ZebraMint

A Stacks blockchain platform for minting personalized NFTs. Users can create unique NFTs with custom metadata including name, description, image URI, and royalty settings.

## Features
- Mint new NFTs with custom metadata
- Set royalty percentages for secondary sales (0-50%)
- Transfer NFTs between users
- View NFT metadata and ownership information
- Update NFT metadata (owner only)
- Burn NFTs permanently
- Track creator royalty information

## Contract Details
The smart contract implements SIP-009 NFT standard and includes:
- NFT minting functionality with royalty settings
- Metadata storage and retrieval with creator tracking
- Transfer capabilities with burned token validation
- Owner-only metadata updates
- Token burning mechanism
- Royalty information tracking

## Royalty System
- Creators can set royalty percentages between 0-50% during minting
- Royalty information is permanently stored with the token
- Royalty percentage and creator address can be queried for any token

## Token Burning
- NFT owners can permanently burn their tokens
- Burned tokens cannot be transferred or updated
- Burning is irreversible and tracked in metadata
