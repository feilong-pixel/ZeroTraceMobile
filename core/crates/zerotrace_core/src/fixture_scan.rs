use crate::grouping::{DuplicateGroup, GroupConfidence, GroupMember};
use crate::scan_item::ScanItem;

pub fn group_fixture_exact_duplicates(items: &[ScanItem]) -> Vec<DuplicateGroup> {
    let mut buckets: std::collections::BTreeMap<FixtureExactKey, Vec<&ScanItem>> =
        std::collections::BTreeMap::new();

    for item in items {
        buckets
            .entry(FixtureExactKey::from(item))
            .or_default()
            .push(item);
    }

    buckets
        .into_iter()
        .filter_map(|(key, members)| {
            if members.len() < 2 {
                return None;
            }

            Some(DuplicateGroup {
                group_id: format!("fixture-exact-{}", key.stable_id()),
                confidence: GroupConfidence::Exact,
                members: members
                    .into_iter()
                    .enumerate()
                    .map(|(index, item)| GroupMember {
                        asset_id: item.asset_id.clone(),
                        selected_for_cleanup: index != 0,
                        keep_recommended: index == 0,
                    })
                    .collect(),
            })
        })
        .collect()
}

#[derive(Debug, Clone, PartialEq, Eq, PartialOrd, Ord)]
struct FixtureExactKey {
    width: u32,
    height: u32,
    size_bytes: u64,
    path_hint: Option<String>,
}

impl FixtureExactKey {
    fn stable_id(&self) -> String {
        format!(
            "{}x{}-{}-{}",
            self.width,
            self.height,
            self.size_bytes,
            self.path_hint.as_deref().unwrap_or("unknown")
        )
        .chars()
        .map(|character| {
            if character.is_ascii_alphanumeric() {
                character
            } else {
                '-'
            }
        })
        .collect()
    }
}

impl From<&ScanItem> for FixtureExactKey {
    fn from(item: &ScanItem) -> Self {
        Self {
            width: item.width,
            height: item.height,
            size_bytes: item.size_bytes,
            path_hint: item.path_hint.clone(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::scan_item::MediaType;

    #[test]
    fn groups_fixture_exact_duplicates_without_platform_access() {
        let items = vec![
            scan_item("asset-a", "fixture/a.jpg", 4000, 3000, 1_024),
            scan_item("asset-b", "fixture/a.jpg", 4000, 3000, 1_024),
            scan_item("asset-c", "fixture/c.jpg", 1200, 800, 2_048),
        ];

        let groups = group_fixture_exact_duplicates(&items);

        assert_eq!(groups.len(), 1);
        assert_eq!(groups[0].confidence, GroupConfidence::Exact);
        assert_eq!(groups[0].members.len(), 2);
        assert_eq!(groups[0].members[0].asset_id, "asset-a");
        assert!(groups[0].members[0].keep_recommended);
        assert!(!groups[0].members[0].selected_for_cleanup);
        assert_eq!(groups[0].members[1].asset_id, "asset-b");
        assert!(!groups[0].members[1].keep_recommended);
        assert!(groups[0].members[1].selected_for_cleanup);
    }

    fn scan_item(
        asset_id: &str,
        path_hint: &str,
        width: u32,
        height: u32,
        size_bytes: u64,
    ) -> ScanItem {
        ScanItem {
            asset_id: asset_id.to_string(),
            path_hint: Some(path_hint.to_string()),
            width,
            height,
            size_bytes,
            created_at: None,
            media_type: MediaType::Image,
        }
    }
}
