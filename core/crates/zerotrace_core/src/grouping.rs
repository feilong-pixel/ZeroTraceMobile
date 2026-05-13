use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum GroupConfidence {
    Exact,
    High,
    Medium,
    Candidate,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct GroupMember {
    pub asset_id: String,
    pub selected_for_cleanup: bool,
    pub keep_recommended: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub struct DuplicateGroup {
    pub group_id: String,
    pub confidence: GroupConfidence,
    pub members: Vec<GroupMember>,
}
