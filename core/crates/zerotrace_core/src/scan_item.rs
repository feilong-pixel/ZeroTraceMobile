use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum MediaType {
    Image,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct ScanItem {
    pub asset_id: String,
    pub path_hint: Option<String>,
    pub width: u32,
    pub height: u32,
    pub size_bytes: u64,
    pub created_at: Option<String>,
    pub media_type: MediaType,
}
